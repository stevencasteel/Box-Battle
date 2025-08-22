# src/entities/components/base_state.gd
## The abstract base class for all entity states.
##
## Defines the lifecycle methods that every state must implement. States are
## responsible for handling logic for a specific entity behavior (e.g., moving,
## attacking, dashing).
class_name BaseState
extends Object

# --- Member Variables ---
var owner: Node
var state_machine: Node
var state_data: Resource

# --- Constructor ---


func _init(p_owner: Node, p_state_machine: Node, p_state_data: Resource) -> void:
	self.owner = p_owner
	self.state_machine = p_state_machine
	self.state_data = p_state_data


# --- Public Methods ---


## Called by the state machine upon exiting to break cyclic references.
func teardown() -> void:
	owner = null
	state_machine = null
	state_data = null


# --- Virtual Lifecycle Methods ---


## Called once when the state machine enters this state.
func enter(_msg := {}) -> void:
	pass


## Called once when the state machine exits this state.
func exit() -> void:
	pass


## Called every physics frame. Used for movement and physics-based logic.
func process_physics(_delta: float) -> void:
	pass


## Called during the `_unhandled_input` cycle. Used for immediate input reactions.
func process_input(_event: InputEvent) -> void:
	pass
