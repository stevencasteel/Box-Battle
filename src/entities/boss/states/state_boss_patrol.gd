# src/entities/boss/states/state_boss_patrol.gd
# The state responsible for the boss's back-and-forth movement.
extends "res://src/entities/boss/states/state_boss_base.gd"
class_name BossStatePatrol

func enter(_msg := {}) -> void:
	boss.patrol_timer.start()

func process_physics(_delta: float) -> void:
	boss.velocity.x = boss.facing_direction * boss.patrol_speed
