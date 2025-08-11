# src/entities/boss/states/state_boss_idle.gd
# The state for when the boss is pausing before an attack.
extends BaseState
class_name BossStateIdle

func enter(_msg := {}):
	owner.velocity.x = 0
	state_machine.change_state(owner.State.ATTACK)

func process_physics(_delta: float):
	# This state is instantaneous, so it does nothing in the physics process.
	pass
