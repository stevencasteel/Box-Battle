# src/entities/player/states/state_move.gd
# Handles the player's grounded movement state.
extends BaseState

func enter(_msg := {}):
	state_data.air_jumps_left = state_data.config.player_max_air_jumps
	state_data.can_dash = true

func process_physics(delta: float):
	state_data.coyote_timer = state_data.config.player_coyote_time
	
	owner.apply_gravity(delta)
	owner.apply_horizontal_movement()

	if not owner.is_on_floor():
		state_machine.change_state(owner.State.FALL)
		return
	
	if owner.input_component.buffer.get("down") and owner.input_component.buffer.get("jump_pressed"):
		if owner.get_last_slide_collision():
			var floor_collider = owner.get_last_slide_collision().get_collider()
			if is_instance_valid(floor_collider) and floor_collider.is_in_group(Identifiers.Groups.ONEWAY_PLATFORMS):
				owner.position.y += 2
				state_machine.change_state(owner.State.FALL)
				return
	
	if owner.input_component.buffer.get("jump_pressed"):
		state_machine.change_state(owner.State.JUMP)
		return