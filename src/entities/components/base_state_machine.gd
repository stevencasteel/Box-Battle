# src/entities/components/base_state_machine.gd
@tool
## A reusable, node-based state machine that conforms to the IComponent interface.
class_name BaseStateMachine
extends IComponent

const MAX_HISTORY_SIZE = 5
var states: Dictionary = {}
var current_state: BaseState
var owner_node: Node
var state_history: Array[String] = []

func _ready() -> void:
	owner_node = get_parent()

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		teardown()

func _unhandled_input(event: InputEvent) -> void:
	if current_state:
		current_state.process_input(event)

func _physics_process(delta: float) -> void:
	if current_state:
		current_state.process_physics(delta)

func _exit_tree() -> void:
	teardown()

func setup(_p_owner: Node, p_dependencies: Dictionary = {}) -> void:
	assert(p_dependencies.has("states"), "StateMachine setup requires a 'states' dictionary.")
	assert(p_dependencies.has("initial_state_key"), "StateMachine setup requires an 'initial_state_key'.")
	self.states = p_dependencies["states"]
	var initial_state_key = p_dependencies["initial_state_key"]
	change_state(initial_state_key)

func teardown() -> void:
	if current_state:
		current_state.exit()
	
	# THE FIX: Since states are now RefCounted, we just call teardown and clear
	# our reference. We DO NOT call .free() on a RefCounted object.
	for state in states.values():
		if is_instance_valid(state):
			state.teardown()
			
	states.clear()
	state_history.clear()
	current_state = null

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
	if is_instance_valid(current_state) and is_instance_valid(current_state.get_script()):
		var state_name = current_state.get_script().resource_path.get_file()
		state_history.push_front(state_name)
		if state_history.size() > MAX_HISTORY_SIZE:
			state_history.pop_back()