# src/core/data/config/combat_config.gd
@tool
## A single, flat Resource that exposes all gameplay tuning values.
##
## This allows designers to balance the game directly in the Godot Inspector
## using organized, range-limited sliders.
class_name CombatConfig
extends Resource

@export_group("Player - Health & Resources")
@export_range(1, 20, 1) var player_max_health: int = 5
@export_range(1, 10, 1) var player_max_healing_charges: int = 1
@export_range(0.1, 5.0, 0.1) var player_heal_duration: float = 2.0
@export_range(1, 100, 1) var player_determination_per_charge: int = 10
@export_range(0.1, 5.0, 0.1) var player_invincibility_duration: float = 1.5

@export_group("Player - Movement & Physics")
@export_range(100, 1000, 5) var player_speed: float = 450.0
@export_range(200, 1500, 10) var player_jump_force: float = 680.0
@export_range(0.1, 1.0, 0.05) var player_jump_release_dampener: float = 0.4
@export_range(0.0, 0.5, 0.01) var player_coyote_time: float = 0.1
@export_range(0.0, 0.5, 0.01) var player_jump_buffer: float = 0.1
@export_range(1.0, 3.0, 0.1) var player_fast_fall_gravity_multiplier: float = 1.4
@export var player_max_air_jumps: int = 1

@export_group("Player - Wall Interaction")
@export_range(50, 500, 5) var player_wall_slide_speed: float = 120.0
@export_range(0.0, 0.5, 0.01) var player_wall_coyote_time: float = 0.05
@export_range(500, 2500, 50) var player_wall_jump_force_x: float = 1650.0
@export_range(200, 1500, 10) var player_wall_jump_force_y: float = 680.0

@export_group("Player - Dash")
@export_range(500, 2500, 50) var player_dash_speed: float = 1400.0
@export_range(0.05, 0.5, 0.01) var player_dash_duration: float = 0.15
@export_range(0.1, 2.0, 0.05) var player_dash_cooldown: float = 0.5

@export_group("Player - Combat")
@export var player_forward_attack_shape: Shape2D
@export var player_upward_attack_shape: Shape2D
@export_range(0.05, 1.0, 0.01) var player_attack_cooldown: float = 0.12
@export_range(0.05, 0.5, 0.01) var player_attack_duration: float = 0.1
@export_range(100, 5000, 100) var player_attack_friction: float = 2000.0
@export_range(0.1, 1.0, 0.01) var player_charge_time: float = 0.35
@export_range(200, 1000, 10) var player_pogo_force: float = 450.0
@export_range(100, 1500, 25) var player_knockback_speed: float = 400.0
@export_range(0.05, 0.5, 0.01) var player_knockback_duration: float = 0.1
@export_range(100, 1500, 25) var player_hazard_knockback_speed: float = 400.0
@export_range(10, 200, 5) var player_close_range_threshold: float = 75.0

@export_group("Boss - General")
@export_range(10, 500, 5) var boss_health: int = 30
@export_range(50, 500, 5) var boss_patrol_speed: float = 100.0
@export_range(0.0, 2.0, 0.01) var boss_invincibility_duration: float = 0.1

@export_group("Boss - Lunge Attack")
@export_range(500, 3000, 50) var boss_lunge_speed: float = 1200.0

@export_group("Minion - Turret")
@export_range(0.5, 5.0, 0.1) var turret_fire_rate: float = 2.0
@export_range(100, 1000, 10) var turret_detection_radius: float = 400.0

@export_group("Projectiles")
@export_range(1, 20, 1) var homing_shot_damage: int = 1
@export_range(100, 1000, 10) var homing_shot_speed: float = 250.0
@export_range(1.0, 20.0, 0.5) var homing_shot_lifespan: float = 10.0

@export_group("Global - Physics")
@export_range(500, 3000, 10) var gravity: float = 1200.0

@export_group("Global - Juice & Feedback (Hit-Stop)")
@export_range(0.0, 0.5, 0.01) var player_melee_close_range_hit_stop_duration: float = 0.025
@export_range(0.0, 0.5, 0.01) var player_damage_taken_hit_stop_duration: float = 0.04
@export_range(0.0, 1.0, 0.01) var boss_phase_change_hit_stop_duration: float = 0.1
@export_range(0.0, 1.0, 0.01) var boss_death_hit_stop_duration: float = 0.2
