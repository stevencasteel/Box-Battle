# src/entities/minions/minion_state_data.gd
## A Resource that holds all shared runtime state data for a Minion.
class_name MinionStateData
extends Resource

# --- Configuration Reference ---
var behavior: MinionBehavior
var services: ServiceLocator

# --- Health & Combat ---
var max_health: int = 3
var health: int = 3:
	set(value):
		health = clamp(value, 0, max_health)

var is_invincible: bool = false
# THE FIX: Add this property back. It's needed by BaseEntity.
var projectile_pool_key: StringName = &""

# --- Targeting ---
var is_player_in_range: bool = false

# --- Physics & Movement ---
var facing_direction: float = -1.0