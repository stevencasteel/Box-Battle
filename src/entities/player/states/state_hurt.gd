# src/entities/player/states/state_hurt.gd
## Handles the player's knockback and stun state after taking damage.
extends BaseState

var _physics: PlayerPhysicsComponent


func enter(_msg := {}) -> void:
	_physics = owner.get_component(PlayerPhysicsComponent)
	state_data.knockback_timer = state_data.config.player_knockback_duration
	state_data.is_charging = false
	owner._cancel_heal()


func process_physics(delta: float) -> void:
	_physics.apply_gravity(delta)
	owner.velocity.x = move_toward(owner.velocity.x, 0, 800 * delta)

	if state_data.knockback_timer <= 0:
		state_machine.change_state(Identifiers.PlayerStates.FALL)