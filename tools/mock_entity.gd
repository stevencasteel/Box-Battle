# tools/mock_entity.gd
## A mock entity for testing components in isolation, particularly for use with
## the DebugOverlay or in unit tests. It provides the properties that various
## systems expect an entity to have, without the overhead of a full scene.
class_name MockEntity
extends Node

# --- Private Member Variables ---
var fx_component: FXComponent
var state_machine: BaseStateMachine
var health_component: HealthComponent


# --- Public Methods ---

## Instantiates and holds component nodes for testing.
func initialize_components() -> void:
	health_component = HealthComponent.new()
	add_child(health_component)
	fx_component = FXComponent.new()
	add_child(fx_component)
	state_machine = BaseStateMachine.new()
	add_child(state_machine)


## Mimics the real BaseEntity's get_component method for test compatibility.
func get_component(type: Script) -> IComponent:
	if type == HealthComponent:
		return health_component
	if type == FXComponent:
		return fx_component
	if type == BaseStateMachine:
		return state_machine
	return null


# Mimic CharacterBody2D methods for the overlay's checks to prevent errors.
func is_on_floor() -> bool:
	return true