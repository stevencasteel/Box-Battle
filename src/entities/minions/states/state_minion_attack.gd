# src/entities/minions/states/state_minion_attack.gd
## The state for when the minion is actively firing at the player.
class_name MinionStateAttack
extends BaseState

# --- Private Member Variables ---
var _minion: Minion

# --- State Lifecycle ---


func enter(_msg := {}) -> void:
	self._minion = owner as Minion
	if not is_instance_valid(_minion):
		return

	_minion._fire_at_player()
	_minion.attack_timer.start(state_data.config.turret_fire_rate)


func process_physics(_delta: float) -> void:
	if not is_instance_valid(_minion):
		return

	if not state_data.is_player_in_range:
		state_machine.change_state(Identifiers.MinionStates.IDLE)
		return

	if _minion.attack_timer.is_stopped():
		_minion._fire_at_player()
		_minion.attack_timer.start(state_data.config.turret_fire_rate)