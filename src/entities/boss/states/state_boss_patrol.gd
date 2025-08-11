# src/entities/boss/states/state_boss_patrol.gd
# The state responsible for the boss's back-and-forth movement.
extends BaseState
class_name BossStatePatrol

func enter(_msg := {}):
	owner.patrol_timer.start()

func process_physics(_delta: float):
	owner.velocity.x = state_data.facing_direction * state_data.patrol_speed
