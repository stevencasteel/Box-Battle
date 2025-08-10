# src/core/data/game_state_data.gd
#
# A Resource that holds all shared runtime state for the game session.
# This standardizes our state management to follow the same pattern as
# PlayerStateData and BossStateData.
class_name GameStateData
extends Resource

# The resource path to the encounter script for the next level to be loaded.
var current_encounter_script_path: String = ""

# A reference to the fully constructed, but currently hidden, level node.
# This is used by the loading screen to pass the level to the game scene.
var prebuilt_level: Node = null