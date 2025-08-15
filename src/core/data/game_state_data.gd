# src/core/data/game_state_data.gd
# A Resource that holds all shared runtime state for the game session.
class_name GameStateData
extends Resource

# THE FIX: Renamed to accurately reflect that it holds a path to a .tres resource, not a script.
var current_encounter_path: String = ""

# A reference to the fully constructed, but currently hidden, level node.
# This is used by the loading screen to pass the level to the game scene.
var prebuilt_level: Node = null