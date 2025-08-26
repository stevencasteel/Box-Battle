# src/entities/minions/states/state_minion_idle.gd
## The default "thinking" state for a minion. It decides what action to take next.
class_name MinionStateIdle
extends BaseState

var _minion: Minion

func enter(_msg := {}) -> void:
	self._minion = owner as Minion
	# An idle minion does not move.
	_minion.velocity = Vector2.ZERO


func process_physics(_delta: float) -> void:
	if not is_instance_valid(_minion):
		return

	# --- State Transition Checks (Prioritized) ---

	# 1. Check for melee attack conditions.
	if state_data.is_player_in_melee_range and _minion.attack_timer.is_stopped():
		state_machine.change_state("melee")
		return

	# 2. Check for ranged attack conditions.
	if state_data.is_player_in_range and _minion.attack_timer.is_stopped():
		if not state_data.behavior.attack_patterns.is_empty():
			state_machine.change_state(Identifiers.MinionStates.ATTACK, {"pattern": state_data.behavior.attack_patterns.pick_random()})
			return

	# 3. If no other action is taken, start patrolling.
	if _minion.attack_timer.is_stopped():
		state_machine.change_state("patrol")
		return