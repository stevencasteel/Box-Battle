# src/entities/base_entity.gd
@tool
## The generic base class for all component-based entities in the game.
class_name BaseEntity
extends CharacterBody2D

# --- Editor Properties ---
@export var archetype: EntityArchetype

# --- Public Member Variables ---
var health_component: HealthComponent
var combat_component: CombatComponent
var input_component: InputComponent
var state_machine: BaseStateMachine
var physics_component: PlayerPhysicsComponent
var ability_component: PlayerAbilityComponent
var resource_component: PlayerResourceComponent
var fx_component: FXComponent

# --- Private Member Variables ---
var _components_initialized: bool = false

# --- Godot Lifecycle Methods ---

func _ready() -> void:
	if Engine.is_editor_hint(): return
	_build_from_archetype()

# --- Public Methods ---

func teardown() -> void:
	for child in get_children():
		if child is IComponent:
			child.teardown()

## Initializes all attached components after dependencies have been injected.
func setup_components(shared_dependencies: Dictionary = {}, per_component_dependencies: Dictionary = {}) -> void:
	if _components_initialized: return

	for child in get_children():
		if not (child is IComponent): continue
		
		var merged_deps := shared_dependencies.duplicate()

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
	for child in get_children():
		if not child is IComponent: continue

		if child is HealthComponent: health_component = child
		elif child is CombatComponent: combat_component = child
		elif child is InputComponent: input_component = child
		elif child is BaseStateMachine: state_machine = child
		elif child is PlayerPhysicsComponent: physics_component = child
		elif child is PlayerAbilityComponent: ability_component = child
		elif child is PlayerResourceComponent: resource_component = child
		elif child is FXComponent: fx_component = child
		else: push_warning("Unbound component on '%s': %s" % [name, child.get_class()])
