# src/entities/boss/states/state_boss_idle.gd
# This state now safely handles cases where no attack patterns are configured.
extends BaseState
class_name BossStateIdle

func enter(_msg := {}):
	owner.velocity.x = 0
	
	# THE FIX: Add a guard clause to prevent a crash if the patterns array is empty.
	if owner.current_attack_patterns.is_empty():
		push_warning("BossStateIdle: No attack patterns defined for the current phase. Defaulting to Cooldown.")
		# Transition to cooldown to prevent getting stuck in an idle->attack loop.
		state_machine.change_state(owner.State.COOLDOWN)
		return
	
	var chosen_pattern = owner.current_attack_patterns[randi() % owner.current_attack_patterns.size()]
	
	state_machine.change_state(owner.State.ATTACK, {"pattern": chosen_pattern})

func process_physics(_delta: float):
	pass
