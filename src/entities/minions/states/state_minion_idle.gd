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

	# 1. Check for falling (unless it's a stationary type).
	if not _minion.is_on_floor():
		var movement_logic = state_data.behavior.movement_logic
		# Only non-stationary minions should fall.
		if not (is_instance_valid(movement_logic) and movement_logic is StationaryMovementLogic):
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
	# If no state transition occurred, perform the default movement logic.
	if is_instance_valid(state_data.behavior.movement_logic):
		var new_velocity: Vector2 = state_data.behavior.movement_logic.execute(
			delta, _minion, state_data
		)
		_minion.velocity = new_velocity