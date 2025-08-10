# src/core/systems/game_manager.gd
#
# A simple singleton to manage the state of the game session. It now holds
# a reference to a GameStateData resource, standardizing our state pattern.
extends Node

# MODIFIED: Removed the parse-time type hint to break the dependency cycle.
var state = null

# Preload the script resource itself. This is safe.
const GameStateDataScript = preload("res://src/core/data/game_state_data.gd")

func _ready():
	# Create a new, clean instance of the game state at runtime,
	# when all scripts have been parsed and registered.
	state = GameStateDataScript.new()