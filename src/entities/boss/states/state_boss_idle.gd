# src/entities/boss/states/state_boss_idle.gd
# This state now chooses an attack from the boss's CURRENT attack pattern list.
extends BaseState
class_name BossStateIdle

func enter(_msg := {}):
	owner.velocity.x = 0
	
	# MODIFIED: Use the dynamic `current_attack_patterns` array.
	var chosen_pattern = owner.current_attack_patterns[randi() % owner.current_attack_patterns.size()]
	
	state_machine.change_state(owner.State.ATTACK, {"pattern": chosen_pattern})

func process_physics(_delta: float):
	pass
