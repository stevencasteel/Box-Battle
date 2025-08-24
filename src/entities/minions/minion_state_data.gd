# src/entities/minions/minion_state_data.gd
## A Resource that holds all shared runtime state data for a Minion.
class_name MinionStateData
extends Resource

# --- Configuration Reference ---
var config: CombatConfig

# --- Health & Combat ---
var max_health: int = 3
var health: int = 3:
	set(value):
		health = clamp(value, 0, max_health)

var is_invincible: bool = false

# --- Targeting ---
var is_player_in_range: bool = false