# src/entities/minions/states/state_turret_idle.gd
## The state for when the turret is inactive and waiting for the player.
extends BaseState
class_name TurretStateIdle

# --- Private Member Variables ---
var _turret: Turret

# --- State Lifecycle ---

func enter(_msg := {}) -> void:
	self._turret = owner as Turret

func exit() -> void:
	if is_instance_valid(_turret):
		_turret.attack_timer.stop()

func process_physics(_delta: float) -> void:
	if not is_instance_valid(_turret): return

	if state_data.is_player_in_range:
		state_machine.change_state(_turret.State.ATTACK)
