# src/core/systems/game_manager.gd
#
# A simple singleton to manage the state of the game session. It now holds
# a reference to a GameStateData resource, standardizing our state pattern.
extends Node

var state = null

const GameStateDataScript = preload("res://src/core/data/game_state_data.gd")

func _ready():
	# Create a new, clean instance of the game state every time the
	# GameManager is initialized.
	state = GameStateDataScript.new()

# NEW: Implement _exit_tree for proper cleanup.
# This function is called automatically by the engine when the game is closing.
func _exit_tree():
	# Manually release our reference to the state resource. This allows
	# Godot's garbage collector to free it and any nodes it might be holding,
	# preventing memory leaks on exit.
	if is_instance_valid(state):
		state = null