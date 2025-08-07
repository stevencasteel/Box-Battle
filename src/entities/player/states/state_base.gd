# src/entities/player/states/state_base.gd
# This is the parent class for all Player states. It defines the "contract"
# that every state must adhere to. It ensures that every state has the necessary
# functions, even if they don't do anything in a particular state.
class_name PlayerState

var player: CharacterBody2D

func _init(player_node: CharacterBody2D):
	self.player = player_node

func enter():
	pass

func exit():
	pass

func process_physics(_delta: float):
	pass

# This function is now used for state-specific input that isn't global,
# like checking for jump release to dampen jump height.
func process_input(_event: InputEvent):
	pass
