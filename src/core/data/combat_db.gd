# src/core/data/combat_db.gd
# This autoload provides global access to the combat config resource.
# It loads the config at runtime in _ready() to be robust against parse-order issues.
extends Node

const CONFIG_PATH: String = "res://data/combat_config.tres"
var config: CombatConfig = null

func _ready() -> void:
	config = load(CONFIG_PATH) as CombatConfig
	if not config:
		push_error("CombatDB: Failed to load CombatConfig at %s" % CONFIG_PATH)
