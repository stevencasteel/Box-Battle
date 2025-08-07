# src/entities/player/states/state_fall.gd
# Handles the player's falling state.
extends PlayerState

func process_physics(delta: float):
	# REFINEMENT: Call the centralized movement function.
	player.apply_horizontal_movement()
	_apply_gravity(delta)

	if player.is_on_floor():
		player.change_state(player.State.MOVE)
		return

	_check_for_wall_slide()

	if player.jump_buffer_timer > 0:
		if player.wall_coyote_timer > 0:
			_perform_wall_jump()
		elif player.coyote_timer > 0:
			player.change_state(player.State.JUMP)
		elif player.air_jumps_left > 0:
			_perform_air_jump()

func _apply_gravity(delta):
	var gravity_multiplier = 1.0
	if Input.is_action_pressed("ui_down"):
		gravity_multiplier = Constants.FAST_FALL_GRAVITY_MULTIPLIER
	player.velocity.y += Constants.GRAVITY * gravity_multiplier * delta

func _check_for_wall_slide():
	if player.wall_coyote_timer > 0 and not player.is_on_floor() and Input.get_axis("ui_left", "ui_right") != 0 and sign(Input.get_axis("ui_left", "ui_right")) == -player.last_wall_normal.x:
		player.change_state(player.State.WALL_SLIDE)

func _perform_air_jump():
	player.air_jumps_left -= 1
	player.change_state(player.State.JUMP)
	
func _perform_wall_jump():
	player.velocity.x = player.last_wall_normal.x * Constants.WALL_JUMP_FORCE_X
	player.coyote_timer = 0
	player.wall_coyote_timer = 0
	player.change_state(player.State.JUMP)
