# src/entities/boss/states/state_boss_cooldown.gd
## The state for when the boss is waiting after completing an attack.
extends BaseState
class_name BossStateCooldown


func enter(_msg := {}) -> void:
	owner.velocity.x = 0
	owner.cooldown_timer.start()
