# src/entities/boss/boss_state_data.gd
## A Resource that holds all shared runtime state data for the Boss.
class_name BossStateData
extends Resource

# --- Configuration Reference ---
var config: CombatConfig

# --- Health & Combat ---
var max_health: int = 30
var health: int = 30:
	set(value):
		health = clamp(value, 0, max_health)

var is_invincible: bool = false

# --- Physics & Movement ---
var facing_direction: float = -1.0