# src/entities/minions/states/state_minion_idle.gd
## The state for when the minion is inactive and waiting for the player.
class_name MinionStateIdle
extends BaseState

# --- Private Member Variables ---
var _minion: Minion

# --- State Lifecycle ---


func enter(_msg := {}) -> void:
	self._minion = owner as Minion


func exit() -> void:
	if is_instance_valid(_minion):
		_minion.attack_timer.stop()


func process_physics(_delta: float) -> void:
	if not is_instance_valid(_minion):
		return

	if state_data.is_player_in_range:
		state_machine.change_state(Identifiers.MinionStates.ATTACK)