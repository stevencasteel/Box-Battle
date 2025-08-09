# src/entities/boss/states/state_boss_patrol.gd
# The state responsible for the boss's back-and-forth movement.
extends "res://src/entities/boss/states/state_boss_base.gd"
class_name BossStatePatrol

func enter(_msg := {}) -> void:
	boss.patrol_timer.start()

func process_physics(_delta: float) -> void:
	# MODIFIED: Read direction and speed from the data object.
	boss.velocity.x = b_data.facing_direction * b_data.patrol_speed
