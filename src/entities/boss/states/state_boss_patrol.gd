# src/entities/boss/states/state_boss_patrol.gd
## A simple state for moving the boss back and forth between attacks.
extends BaseState
class_name BossStatePatrol

func enter(_msg := {}) -> void:
	owner.patrol_timer.start()

func process_physics(_delta: float) -> void:
	owner.velocity.x = state_data.facing_direction * state_data.config.boss_patrol_speed
