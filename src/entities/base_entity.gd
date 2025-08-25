# src/entities/base_entity.gd
@tool
## The generic base class for all component-based entities in the game.
class_name BaseEntity
extends CharacterBody2D

# --- Editor Properties ---
@export var archetype: EntityArchetype

# --- Public Member Variables ---
var _is_dead: bool = false

# --- Private Member Variables ---
var _components_initialized: bool = false
var _services: ServiceLocator
var _components: Dictionary = {}
var _components_by_interface: Dictionary = {}
var _player: CharacterBody2D
var _active_attack_tween: Tween


# --- Godot Lifecycle Methods ---
func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_build_from_archetype()
	if not Engine.is_editor_hint():
		_player = get_tree().get_first_node_in_group(Identifiers.Groups.PLAYER)


# --- Public Methods ---
## Retrieves a component from this entity by its script type or an interface it implements.
func get_component(type: Script) -> IComponent:
	if _components.has(type):
		return _components.get(type)

	if _components_by_interface.has(type):
		return _components_by_interface.get(type)

	return null


## Helper that asserts and provides a clear error if a required component is missing.
func require_component(type: Script) -> IComponent:
	var c = get_component(type)
	if not is_instance_valid(c):
		push_error("Missing required component: %s on entity %s" % [type.resource_path, name])
	return c


func inject_dependencies(p_services: ServiceLocator) -> void:
	_services = p_services


func teardown() -> void:
	for child in get_children():
		if child is IComponent:
			child.teardown()


func setup_components(
	shared_dependencies: Dictionary = {}, per_component_dependencies: Dictionary = {}
) -> void:
	if _components_initialized:
		return

	var base_shared_deps = shared_dependencies.duplicate()
	base_shared_deps["services"] = _services

	for child in get_children():
		if not (child is IComponent):
			continue

		var class_key: String = child.get_script().get_global_name()

		if child.has_meta("REQUIRED_DEPS"):
			var required = child.get_meta("REQUIRED_DEPS")
			var all_deps_for_check = base_shared_deps.duplicate()
			if per_component_dependencies.has(child):
				all_deps_for_check.merge(per_component_dependencies[child])
			
			if per_component_dependencies.has(class_key):
				all_deps_for_check.merge(per_component_dependencies[class_key])

			if not DependencyValidator.validate(child, all_deps_for_check, required):
				push_error("Dependency validation failed for %s. Aborting entity setup." % child.name)
				return

		var merged_deps := base_shared_deps.duplicate()

		if per_component_dependencies.has(child):
			merged_deps.merge(per_component_dependencies[child])

		if per_component_dependencies.has(class_key):
			merged_deps.merge(per_component_dependencies[class_key])

		if child.has_method("setup"):
			child.setup(self, merged_deps)

	_components_initialized = true


# --- Generic Attack Implementations ---
func fire_volley(shot_count: int, delay: float) -> void:
	if is_instance_valid(_active_attack_tween):
		_active_attack_tween.kill()
	_active_attack_tween = get_tree().create_tween()
	for i in range(shot_count):
		_active_attack_tween.tween_callback(fire_shot_at_player)
		if i < shot_count - 1:
			_active_attack_tween.tween_interval(delay)


func fire_shot_at_player() -> void:
	if _is_dead or not is_instance_valid(_player):
		return

	var pool_key: StringName = self.entity_data.projectile_pool_key
	if pool_key == &"":
		push_warning("Entity '%s' tried to fire a shot but has no 'projectile_pool_key' in its data." % name)
		return

	var shot: Node = _services.object_pool.get_instance(pool_key)
	if not shot:
		return

	_update_player_tracking()

	shot.direction = (_player.global_position - global_position).normalized()
	shot.global_position = global_position
	shot.activate(_services)


# --- Protected Virtual Methods (for children to override) ---
## A virtual method for child classes to implement their own tracking logic.
func _update_player_tracking() -> void:
	pass # Default implementation does nothing.


# --- Private Methods ---
func _build_from_archetype() -> void:
	if not is_instance_valid(archetype):
		push_error("Entity '%s' is missing its Archetype resource." % name)
		return

	for component_scene in archetype.components:
		if is_instance_valid(component_scene):
			var component_instance = component_scene.instantiate()
			add_child(component_instance)
		else:
			push_warning("Archetype for '%s' contains an invalid component scene." % name)

	_cache_components_by_type()


func _cache_components_by_type() -> void:
	_components.clear()
	_components_by_interface.clear()
	
	for child in get_children():
		if not child is IComponent:
			continue

		var component_script: Script = child.get_script()
		_components[component_script] = child
		
		var base_script: Script = component_script.get_base_script()
		while is_instance_valid(base_script):
			if base_script.resource_path.is_empty() or base_script == IComponent:
				break
			_components_by_interface[base_script] = child
			base_script = base_script.get_base_script()
