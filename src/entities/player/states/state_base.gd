# src/entities/player/states/state_base.gd
# This is the parent class for all Player states. It defines the "contract"
# that every state must adhere to.
class_name PlayerState

var player: CharacterBody2D
var p_data: PlayerStateData # NEW: Reference to the shared state data

# MODIFIED: The constructor now accepts the state data resource.
func _init(player_node: CharacterBody2D, player_data: PlayerStateData):
	self.player = player_node
	self.p_data = player_data

func enter():
	pass

func exit():
	pass

func process_physics(_delta: float):
	pass

func process_input(_event: InputEvent):
	pass
