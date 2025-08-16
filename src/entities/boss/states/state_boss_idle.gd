# src/entities/boss/states/state_boss_idle.gd
## A transient state that immediately selects the next attack pattern.
class_name BossStateIdle
extends BaseState

func enter(_msg := {}) -> void:
	owner.velocity.x = 0

	if owner.current_attack_patterns.is_empty():
		push_warning("BossStateIdle: No attack patterns defined for current phase. Defaulting to Cooldown.")
		state_machine.change_state(owner.State.COOLDOWN)
		return

	var chosen_pattern: AttackPattern = owner.current_attack_patterns.pick_random()
	state_machine.change_state(owner.State.ATTACK, {"pattern": chosen_pattern})
