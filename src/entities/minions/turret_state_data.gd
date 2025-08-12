# src/entities/minions/turret_state_data.gd
# A Resource that holds all shared state data for the Turret minion.
class_name TurretStateData
extends Resource

# --- Health & Combat ---
var max_health: int = 3
var health: int = 3:
	set(value):
		health = clamp(value, 0, max_health)

var is_invincible: bool = false

# --- Targeting ---
var is_player_in_range: bool = false
