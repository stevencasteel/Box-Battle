# src/entities/player/states/state_move.gd
## Handles the player's grounded movement state.
extends BaseState

var _physics: PlayerPhysicsComponent


func enter(_msg := {}) -> void:
	_physics = owner.get_component(PlayerPhysicsComponent)
	state_data.air_jumps_left = state_data.config.player_max_air_jumps
	state_data.can_dash = true


func process_physics(delta: float) -> void:
	state_data.coyote_timer = state_data.config.player_coyote_time

	_physics.apply_gravity(delta)
	_physics.apply_horizontal_movement()

	if not owner.is_on_floor():
		state_machine.change_state(Identifiers.PlayerStates.FALL)
		return

