# src/entities/player/states/state_hurt.gd
# This state now correctly implements a short stun duration, decoupled
# from the longer invincibility timer.
extends BaseState

func enter(_msg := {}):
	state_data.knockback_timer = state_data.config.player_knockback_duration
	state_data.is_charging = false
	owner._cancel_heal()

func process_physics(delta: float):
	owner.apply_gravity(delta)
	owner.velocity.x = move_toward(owner.velocity.x, 0, 800 * delta)

	if state_data.knockback_timer <= 0:
		state_machine.change_state(owner.State.FALL)