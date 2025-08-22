# src/entities/player/states/state_hurt.gd
## Handles the player's knockback and stun state after taking damage.
extends BaseState


func enter(_msg := {}) -> void:
	state_data.knockback_timer = state_data.config.player_knockback_duration
	state_data.is_charging = false
	owner._cancel_heal()


func process_physics(delta: float) -> void:
	owner.physics_component.apply_gravity(delta)
	owner.velocity.x = move_toward(owner.velocity.x, 0, 800 * delta)

	if state_data.knockback_timer <= 0:
		state_machine.change_state(owner.State.FALL)
