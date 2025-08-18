# src/core/data/combat_db.gd
## An autoloaded singleton that provides global, read-only access to the
## main combat configuration resource file.
extends Node

# --- Constants ---
const CONFIG_PATH: String = "res://src/data/combat_config.tres"

# --- Public Member Variables ---
## A reference to the loaded [CombatConfig] resource.
var config: CombatConfig = null

# --- Godot Lifecycle Methods ---

func _ready() -> void:
	config = load(CONFIG_PATH) as CombatConfig
	if not config:
		push_error("CombatDB: Failed to load CombatConfig at %s" % CONFIG_PATH)