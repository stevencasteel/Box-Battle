# src/entities/minions/states/state_turret_attack.gd
# The state for when the turret is actively firing. The re-firing logic
# is now correctly placed in process_physics.
extends BaseState
class_name TurretStateAttack

var turret: Turret

func enter(_msg := {}):
	self.turret = owner as Turret
	if not turret: return
	
	# Fire the first shot immediately upon entering the state.
	turret.fire_at_player()
	turret.attack_timer.start(turret.fire_rate)

func process_physics(_delta: float):
	if not turret: return

	# Condition 1: If the player leaves the detection range, go back to idle.
	if not state_data.is_player_in_range:
		state_machine.change_state(turret.State.IDLE)
		return

	# Condition 2: If the attack cooldown has finished, fire again.
	if turret.attack_timer.is_stopped():
		turret.fire_at_player()
		turret.attack_timer.start(turret.fire_rate)
