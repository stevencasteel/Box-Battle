# src/entities/boss/states/state_boss_cooldown.gd
# The state for when the boss is waiting after an attack.
extends BaseState
class_name BossStateCooldown

func enter(_msg := {}):
	owner.velocity.x = 0
	owner.cooldown_timer.start()

func process_physics(_delta: float):
	# The state itself does nothing; it's just waiting for the timer.
	pass
