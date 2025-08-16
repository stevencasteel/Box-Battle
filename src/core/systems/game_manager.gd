# src/core/systems/game_manager.gd
## An autoloaded singleton that manages the state of the game session.
##
## It holds a reference to a [GameStateData] resource, which acts as the
## single source of truth for all runtime session data.
extends Node

# --- Constants ---
const GameStateDataScript = preload("res://src/core/data/game_state_data.gd")

# --- Public Member Variables ---
## The active [GameStateData] resource for the current session.
var state: GameStateData = null

# --- Godot Lifecycle Methods ---

func _ready() -> void:
	# Create a new, clean instance of the game state every time the
	# GameManager is initialized at game startup.
	state = GameStateDataScript.new()

func _exit_tree() -> void:
	# Manually release our reference to the state resource. This allows
	# Godot's garbage collector to free it, preventing memory leaks on exit.
	if is_instance_valid(state):
		state = null