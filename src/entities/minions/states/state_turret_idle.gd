# src/entities/minions/states/state_turret_idle.gd
# The state for when the turret is waiting for the player.
extends BaseState
class_name TurretStateIdle

var turret: Turret

func enter(_msg := {}):
	self.turret = owner as Turret
	if not turret: return

func exit():
	# Ensure the timer is stopped so the Attack state starts fresh.
	if is_instance_valid(turret):
		turret.attack_timer.stop()

func process_physics(_delta: float):
	if not turret: return
	
	if state_data.is_player_in_range:
		state_machine.change_state(turret.State.ATTACK)