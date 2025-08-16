# src/entities/components/base_state_machine.gd
@tool
## A reusable, node-based state machine that conforms to the ComponentInterface.
##
## Manages a dictionary of [BaseState] objects, handles transitions between
## them, and forwards engine callbacks to the active state.
class_name BaseStateMachine
extends ComponentInterface

# --- Member Variables ---
## A dictionary of all states available to this machine, keyed by an enum.
var states: Dictionary = {}
## A reference to the currently active state object.
var current_state: BaseState
## A reference to the node that owns this state machine.
var owner_node: Node

# --- Godot Lifecycle Methods ---

func _ready() -> void:
	owner_node = get_parent()

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.process_input(event)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.process_physics(delta)

func _exit_tree() -> void:
	teardown()

# --- Public Methods ---

## Initializes the state machine with states and an initial state.
func setup(_p_owner: Node, p_dependencies: Dictionary = {}) -> void:
	assert(p_dependencies.has("states"), "StateMachine setup requires a 'states' dictionary.")
	assert(p_dependencies.has("initial_state_key"), "StateMachine setup requires an 'initial_state_key'.")

	self.states = p_dependencies["states"]
	var initial_state_key = p_dependencies["initial_state_key"]

	change_state(initial_state_key)

## Safely cleans up all states to prevent memory leaks.
func teardown() -> void:
	if current_state:
		current_state.exit()
	for state in states.values():
		if state.has_method("teardown"):
			state.teardown()
	states.clear()
	current_state = null

## Transitions the machine from the current state to a new one.
func change_state(new_state_key, msg := {}) -> void:
	if not states.has(new_state_key):
		push_warning("StateMachine: Attempted to change to unknown state '%s'." % new_state_key)
		return

	if current_state == states.get(new_state_key):
		return

	if current_state:
		current_state.exit()

	current_state = states[new_state_key]
	current_state.enter(msg)