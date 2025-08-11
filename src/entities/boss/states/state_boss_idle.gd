# src/entities/boss/states/state_boss_idle.gd
# This state is now responsible for CHOOSING an attack and passing
# the corresponding AttackPattern resource to the AttackState.
extends BaseState
class_name BossStateIdle

func enter(_msg := {}):
	owner.velocity.x = 0
	
	# Randomly select one of the available attack patterns.
	var chosen_pattern = owner.attack_patterns[randi() % owner.attack_patterns.size()]
	
	# Transition to the AttackState, passing the chosen pattern in the message dictionary.
	state_machine.change_state(owner.State.ATTACK, {"pattern": chosen_pattern})

func process_physics(_delta: float):
	# This state is instantaneous.
	pass
