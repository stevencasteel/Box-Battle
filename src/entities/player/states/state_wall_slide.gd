# src/entities/player/states/state_wall_slide.gd
# Handles the player's wall sliding state.
extends BaseState


func enter(_msg := {}):
	state_data.can_dash = true
	state_data.air_jumps_left = state_data.config.player_max_air_jumps


func exit():
	if state_data.last_wall_normal != Vector2.ZERO:
		state_data.facing_direction = sign(state_data.last_wall_normal.x)


func process_physics(delta: float):
	var gravity = state_data.config.gravity
	var wall_slide_speed = state_data.config.player_wall_slide_speed
	owner.velocity.y = min(owner.velocity.y + gravity * delta, wall_slide_speed)

	state_data.facing_direction = sign(-state_data.last_wall_normal.x)

	if owner.input_component.buffer.get("jump_just_pressed"):
		owner.physics_component.perform_wall_jump()
		state_machine.change_state(owner.State.JUMP)
		return

	var move_axis = owner.input_component.buffer.get("move_axis", 0.0)
	if move_axis * -state_data.last_wall_normal.x < 0.8:
		state_machine.change_state(owner.State.FALL)
		return

	if state_data.wall_coyote_timer <= 0:
		state_machine.change_state(owner.State.FALL)
		return

	if owner.is_on_floor():
		state_machine.change_state(owner.State.MOVE)
		return