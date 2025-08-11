# src/entities/components/base_state.gd
#
# The single, unified base class for all state machine states in the project.
# It defines the "contract" that every state must adhere to.
class_name BaseState
extends Object

var owner: Node
var state_machine: Node
var state_data: Resource

func _init(p_owner: Node, p_state_machine: Node, p_state_data: Resource):
	self.owner = p_owner
	self.state_machine = p_state_machine
	self.state_data = p_state_data

# NEW: Teardown function to break cyclic references.
func teardown():
	owner = null
	state_machine = null
	state_data = null

func enter(_msg := {}):
	pass

func exit():
	pass

func process_physics(_delta: float):
	pass

func process_input(_event: InputEvent):
	pass