# src/core/game_manager.gd
#
# A simple singleton to manage the state of the game session, such as
# which level is currently being loaded or played.
extends Node

# This variable will hold the resource path to the encounter script for the
# level that the player has chosen to play.
var current_encounter_script_path: String = ""

# --- NEW VARIABLE ---
# This will hold the fully constructed, but currently hidden, level node.
var prebuilt_level: Node = null