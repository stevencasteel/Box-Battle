# src/entities/minions/states/state_minion_idle.gd
## The default state for a minion. It handles movement via the assigned
## MovementLogic and checks for conditions to transition to the attack state.
class_name MinionStateIdle
extends BaseState

var _minion: Minion


func enter(_msg := {}) -> void:
	self._minion = owner as Minion


func process_physics(delta: float) -> void:
	if not is_instance_valid(_minion):
		return

	# Delegate movement logic to the assigned strategy.
	if is_instance_valid(state_data.behavior.movement_logic):
		var new_velocity: Vector2 = state_data.behavior.movement_logic.execute(
			delta, _minion, state_data
		)
		_minion.velocity = new_velocity
	
	# THE FIX: The state machine no longer applies gravity. This is now the
	# sole responsibility of the active MovementLogic resource.

	# Check for attack conditions.
	if state_data.is_player_in_range and _minion.attack_timer.is_stopped():
		state_machine.change_state(Identifiers.MinionStates.ATTACK)