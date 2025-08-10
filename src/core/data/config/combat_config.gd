# src/core/data/config/combat_config.gd
# A single, flat Resource that exposes all combat tuning values.
class_name CombatConfig
extends Resource

@export_group("General Physics")
@export var gravity: float = 1200.0

@export_group("Player Physics")
@export var player_speed: float = 450.0
@export var player_jump_force: float = 680.0
@export var player_pogo_force: float = 450.0
@export var player_coyote_time: float = 0.1
@export var player_jump_buffer: float = 0.1
@export var player_jump_release_dampener: float = 0.4
@export var player_wall_coyote_time: float = 0.05
@export var player_fast_fall_gravity_multiplier: float = 1.4
@export var player_max_air_jumps: int = 0
@export var player_dash_speed: float = 1400.0
@export var player_dash_duration: float = 0.15
@export var player_dash_cooldown: float = 0.5
@export var player_wall_slide_speed: float = 120.0
@export var player_wall_jump_force_x: float = 1650.0
@export var player_wall_jump_force_y: float = 680.0

@export_group("Player Combat")
@export var player_attack_cooldown: float = 0.12
@export var player_charge_time: float = 0.35
@export var player_attack_duration: float = 0.1
@export var player_attack_friction: float = 2000.0
@export var player_knockback_speed: float = 700.0
@export var player_knockback_duration: float = 0.1
@export var player_hazard_knockback_speed: float = 400.0
@export var player_determination_per_charge: int = 10

@export_group("Player Health / Healing")
@export var player_max_health: int = 5
@export var player_heal_duration: float = 2.0
@export var player_max_healing_charges: int = 1
@export var player_invincibility_duration: float = 1.5

@export_group("Boss")
@export var boss_health: int = 30
@export var boss_patrol_speed: float = 100.0
@export var boss_invincibility_duration: float = 0.1