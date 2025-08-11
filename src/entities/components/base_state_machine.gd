# src/entities/components/base_state_machine.gd
#
# A reusable, node-based state machine manager. An entity (like Player or Boss)
# will own this node and use it to manage its states.
class_name BaseStateMachine
extends Node

var states: Dictionary = {}
var current_state: BaseState
var owner_node: Node

func _ready():
	owner_node = get_parent()

func _unhandled_input(event: InputEvent):
	if current_state:
		current_state.process_input(event)

func _physics_process(delta: float):
	if current_state:
		current_state.process_physics(delta)

func setup(p_states: Dictionary, p_initial_state_key):
	self.states = p_states
	change_state(p_initial_state_key)

# CORRECTED: The teardown function is restored.
func teardown():
	if current_state:
		current_state.exit()
	# Call teardown on each individual state to break cyclic references.
	for state in states.values():
		if state.has_method("teardown"):
			state.teardown()
	states.clear()
	current_state = null

func change_state(new_state_key, msg := {}):
	if not states.has(new_state_key):
		push_warning("StateMachine: Attempted to change to unknown state '%s'." % new_state_key)
		return

	if current_state == states[new_state_key]:
		return

	if current_state:
		current_state.exit()

	current_state = states[new_state_key]
	current_state.enter(msg)

func _exit_tree():
	# Call teardown on exit to be safe, though the owner should call it first.
	teardown()