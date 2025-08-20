# src/entities/player/states/state_move.gd
## Handles the player's grounded movement state.
extends BaseState

func enter(_msg := {}) -> void:
	state_data.air_jumps_left = state_data.config.player_max_air_jumps
	state_data.can_dash = true

func process_physics(delta: float) -> void:
	state_data.coyote_timer = state_data.config.player_coyote_time

	owner.physics_component.apply_gravity(delta)
	owner.physics_component.apply_horizontal_movement()

	if not owner.is_on_floor():
		state_machine.change_state(owner.State.FALL)
		return