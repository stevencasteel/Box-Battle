# src/entities/minions/states/state_minion_idle.gd
## The default state for a minion. It handles movement via the assigned
## MovementLogic and checks for conditions to transition to other states.
class_name MinionStateIdle
extends BaseState

var _minion: Minion


func enter(_msg := {}) -> void:
	self._minion = owner as Minion


func process_physics(delta: float) -> void:
	if not is_instance_valid(_minion):
		return

	# --- State Transition Checks (Prioritized) ---

	# 1. Check for falling (ONLY if the entity is not anchored).
	# This is the definitive fix. An anchored entity should never fall.
	if not state_data.behavior.is_anchored and not _minion.is_on_floor():
		state_machine.change_state(Identifiers.MinionStates.FALL)
		return

	# 2. Check for attack conditions.
	var can_attack: bool = (
		state_data.is_player_in_range
		and _minion.attack_timer.is_stopped()
		and not state_data.behavior.attack_patterns.is_empty()
	)
	if can_attack:
		state_machine.change_state(Identifiers.MinionStates.ATTACK, {"pattern": state_data.behavior.attack_patterns.pick_random()})
		return

	# --- Default Action: Execute Movement ---
	if is_instance_valid(state_data.behavior.movement_logic):
		var new_velocity: Vector2 = state_data.behavior.movement_logic.execute(
			delta, _minion, state_data
		)
		_minion.velocity = new_velocity