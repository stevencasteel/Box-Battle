# src/entities/boss/states/state_boss_cooldown.gd
# The state for when the boss is waiting after an attack.
extends "res://src/entities/boss/states/state_boss_base.gd"
class_name BossStateCooldown

func enter(_msg := {}) -> void:
	boss.velocity.x = 0
	boss.cooldown_timer.start()

func process_physics(_delta: float) -> void:
	# The state itself does nothing; it's just waiting for the timer.
	pass
