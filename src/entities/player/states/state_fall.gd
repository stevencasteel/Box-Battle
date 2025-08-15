# src/entities/player/states/state_fall.gd
# Handles the player's falling state.
extends BaseState

func process_physics(delta: float):
	owner.apply_horizontal_movement()
	_apply_gravity(delta)

	if owner.is_on_floor():
		state_machine.change_state(owner.State.MOVE)
		return

	_check_for_wall_slide()

	if owner.input_component.buffer.get("jump_pressed"):
		if state_data.wall_coyote_timer > 0:
			_perform_wall_jump()
		elif state_data.coyote_timer > 0:
			state_machine.change_state(owner.State.JUMP)
		elif state_data.air_jumps_left > 0:
			_perform_air_jump()

func _apply_gravity(delta):
	var gravity_multiplier = 1.0
	if owner.input_component.buffer.get("down"):
		gravity_multiplier = state_data.config.player_fast_fall_gravity_multiplier
	owner.apply_gravity(delta, gravity_multiplier)

func _check_for_wall_slide():
	var move_axis = owner.input_component.buffer.get("move_axis", 0.0)
	if state_data.wall_coyote_timer > 0 and not owner.is_on_floor() and move_axis != 0 and sign(move_axis) == -state_data.last_wall_normal.x:
		state_machine.change_state(owner.State.WALL_SLIDE)

func _perform_air_jump():
	state_data.air_jumps_left -= 1
	state_machine.change_state(owner.State.JUMP)
	
func _perform_wall_jump():
	owner.velocity.x = state_data.last_wall_normal.x * state_data.config.player_wall_jump_force_x
	state_data.coyote_timer = 0
	state_data.wall_coyote_timer = 0
	state_machine.change_state(owner.State.JUMP)