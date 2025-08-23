# tools/mock_entity.gd
## A mock entity for testing components in isolation, particularly for use with
## the DebugOverlay or in unit tests. It provides the properties that various
## systems expect an entity to have, without the overhead of a full scene.
class_name MockEntity
extends Node

@export var fx_component: FXComponent
@export var state_machine: BaseStateMachine
@export var health_component: HealthComponent


# --- Public Methods (Mimicking BaseEntity) ---

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