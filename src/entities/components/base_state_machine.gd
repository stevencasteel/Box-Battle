# src/entities/components/base_state_machine.gd
#
# A reusable, node-based state machine manager. It now conforms to the
# ComponentInterface contract for a unified entity architecture.
class_name BaseStateMachine
extends ComponentInterface

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

func setup(_p_owner: Node, p_dependencies: Dictionary = {}) -> void:
	# The setup method now conforms to the standard interface.
	# It expects a dictionary containing the states and the initial state key.
	assert(p_dependencies.has("states"), "StateMachine setup requires a 'states' dictionary.")
	assert(p_dependencies.has("initial_state_key"), "StateMachine setup requires an 'initial_state_key'.")
	
	self.states = p_dependencies["states"]
	var initial_state_key = p_dependencies["initial_state_key"]
	
	change_state(initial_state_key)

func teardown():
	if current_state:
		current_state.exit()
	for state in states.values():
		if state.has_method("teardown"):
			state.teardown()
	states.clear()
	current_state = null

func change_state(new_state_key, msg := {}):
	if not states.has(new_state_key):
		push_warning("StateMachine: Attempted to change to unknown state '%s'." % new_state_key)
		return

	if current_state == states.get(new_state_key):
		return

	if current_state:
		current_state.exit()

	current_state = states[new_state_key]
	current_state.enter(msg)

func _exit_tree():
	teardown()