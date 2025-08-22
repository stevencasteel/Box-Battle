# src/core/data/game_state_data.gd
## A Resource that holds all shared runtime state for the game session.
class_name GameStateData
extends Resource

# --- Member Variables ---
## The full 'res://' path to the [EncounterData] resource for the current level.
var current_encounter_path: String = ""
## A reference to the fully constructed, but currently hidden, level node.
var prebuilt_level: Node = null
