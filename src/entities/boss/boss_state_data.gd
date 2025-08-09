# src/entities/boss/data/boss_state_data.gd
#
# A Resource that holds all shared state data for the Boss. This decouples
# the states from the main boss node.
class_name BossStateData
extends Resource

# --- Health & Combat ---
var health: int = 30
var is_invincible: bool = false
var current_attack: int # Using the enum from base_boss.gd

# --- Physics & Movement ---
var facing_direction: float = -1.0
var patrol_speed: float = 100.0