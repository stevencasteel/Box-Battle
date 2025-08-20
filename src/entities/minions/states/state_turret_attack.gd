# src/entities/minions/states/state_turret_attack.gd
## The state for when the turret is actively firing at the player.
extends BaseState
class_name TurretStateAttack

# --- Private Member Variables ---
var _turret: Turret

# --- State Lifecycle ---

func enter(_msg := {}) -> void:
	self._turret = owner as Turret
	if not is_instance_valid(_turret): return

	_turret._fire_at_player()
	_turret.attack_timer.start(state_data.config.turret_fire_rate)

func process_physics(_delta: float) -> void:
	if not is_instance_valid(_turret): return

	if not state_data.is_player_in_range:
		state_machine.change_state(_turret.State.IDLE)
		return

	if _turret.attack_timer.is_stopped():
		_turret._fire_at_player()
		_turret.attack_timer.start(state_data.config.turret_fire_rate)