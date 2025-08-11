# src/entities/player/states/state_hurt.gd
# This state now correctly implements a short stun duration, decoupled
# from the longer invincibility timer.
extends BaseState

func enter(_msg := {}):
	# Start the dedicated knockback timer using the value from our new config resource.
	state_data.knockback_timer = CombatDB.config.player_knockback_duration
	
	# These actions are still relevant.
	state_data.is_charging = false
	owner._cancel_heal()


func process_physics(delta: float):
	# Apply gravity and air friction to the existing knockback velocity.
	owner.velocity.y += CombatDB.config.gravity * delta
	owner.velocity.x = move_toward(owner.velocity.x, 0, 800 * delta)

	# CRITICAL FIX: The state now ends when the SHORT knockback timer runs out,
	# not when the LONG invincibility wears off.
	if state_data.knockback_timer <= 0:
		state_machine.change_state(owner.State.FALL)