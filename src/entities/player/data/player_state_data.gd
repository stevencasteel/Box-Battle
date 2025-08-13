# src/entities/player/data/player_state_data.gd
#
# A Resource that holds all shared state data for the Player. It now includes
# validation logic in its setters and a dictionary to track melee hits.
class_name PlayerStateData
extends Resource

# --- Health & Combat ---
var max_health: int = 5
var max_healing_charges: int = 1

var health: int = 5:
	set(value):
		health = clamp(value, 0, max_health)

var healing_charges: int = 0:
	set(value):
		healing_charges = clamp(value, 0, max_healing_charges)

var determination_counter: int = 0
var is_invincible: bool = false
var is_dash_invincible: bool = false
var hit_targets_this_swing: Dictionary = {} # NEW: Tracks entities hit in one swing.

# --- Physics & Movement ---
var air_jumps_left: int = 0
var facing_direction: int = 1
var last_wall_normal: Vector2 = Vector2.ZERO
var can_dash: bool = true
var pogo_fall_prevention_timer: float = 0.0 # NEW: For pogo-fall prevention

# --- Timers ---
var coyote_timer: float = 0.0
var jump_buffer_timer: float = 0.0
var wall_coyote_timer: float = 0.0
var dash_duration_timer: float = 0.0
var dash_cooldown_timer: float = 0.0
var attack_duration_timer: float = 0.0
var attack_cooldown_timer: float = 0.0
var knockback_timer: float = 0.0

# --- State Flags ---
var is_charging: bool = false
var charge_timer: float = 0.0
var is_pogo_attack: bool = false