# src/entities/base_entity.gd
@tool
## The generic base class for all component-based entities in the game.
class_name BaseEntity
extends CharacterBody2D

# --- Editor Properties ---
@export var archetype: EntityArchetype

# --- Private Member Variables ---
var _components_initialized: bool = false
var _services: ServiceLocator
var _components: Dictionary = {}

# --- Godot Lifecycle Methods ---


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	_build_from_archetype()


# --- Public Methods ---


## Retrieves a component from this entity by its script type.
func get_component(type: Script) -> IComponent:
	return _components.get(type)


## Helper that asserts and provides a clear error if a required component is missing.
func require_component(type: Script) -> IComponent:
	var c = get_component(type)
	if not is_instance_valid(c):
		push_error("Missing required component: %s on entity %s" % [type.resource_path, name])
	return c


## Called by the entity creator (ArenaBuilder) before the entity enters the scene tree.
func inject_dependencies(p_services: ServiceLocator) -> void:
	_services = p_services


func teardown() -> void:
	for child in get_children():
		if child is IComponent:
			child.teardown()


## Initializes all attached components after dependencies have been injected.
func setup_components(
	shared_dependencies: Dictionary = {}, per_component_dependencies: Dictionary = {}
) -> void:
	if _components_initialized:
		return

	# THE FIX: Add the services locator to the shared dependencies for all components.
	var base_shared_deps = shared_dependencies.duplicate()
	base_shared_deps["services"] = _services

	for child in get_children():
		if not (child is IComponent):
			continue

		var merged_deps := base_shared_deps.duplicate()

		if per_component_dependencies.has(child):
			merged_deps.merge(per_component_dependencies[child])

		var class_key: String = child.get_script().get_global_name()
		if per_component_dependencies.has(class_key):
			merged_deps.merge(per_component_dependencies[class_key])

		if child.has_method("setup"):
			child.setup(self, merged_deps)

	_components_initialized = true


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
	for child in get_children():
		if not child is IComponent:
			continue

		_components[child.get_script()] = child
