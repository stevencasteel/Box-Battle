# src/entities/boss/states/state_boss_idle.gd
# The state for when the boss is pausing before an attack.
extends "res://src/entities/boss/states/state_boss_base.gd"
class_name BossStateIdle

func enter(_msg := {}) -> void:
	boss.velocity.x = 0
	boss.change_state(boss.State.ATTACK)

func process_physics(_delta: float) -> void:
	# This state is instantaneous, so it does nothing in the physics process.
	pass
