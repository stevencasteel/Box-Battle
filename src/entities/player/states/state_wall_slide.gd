# src/entities/player/states/state_wall_slide.gd
# Handles the player's wall sliding state.
extends PlayerState

func enter():
	player.can_dash = true
	player.air_jumps_left = Constants.MAX_AIR_JUMPS

func exit():
	if player.last_wall_normal != Vector2.ZERO:
		player.facing_direction = player.last_wall_normal.x

func process_physics(delta: float):
	player.velocity.y = min(player.velocity.y + Constants.GRAVITY * delta, Constants.WALL_SLIDE_SPEED)
	player.facing_direction = -player.last_wall_normal.x
	
	if player.jump_buffer_timer > 0:
		_perform_wall_jump()
		return
	
	# Check if player is no longer holding into the wall
	if Input.get_axis("ui_left", "ui_right") * -player.last_wall_normal.x < 0.8:
		player.change_state(player.State.FALL)
		return
		
	# Check if wall coyote time has run out
	if player.wall_coyote_timer <= 0:
		player.change_state(player.State.FALL)
		return

	if player.is_on_floor():
		player.change_state(player.State.MOVE)
		return

func _perform_wall_jump():
	player.velocity.y = -Constants.WALL_JUMP_FORCE_Y
	player.velocity.x = player.last_wall_normal.x * Constants.WALL_JUMP_FORCE_X
	player.jump_buffer_timer = 0
	player.coyote_timer = 0
	player.wall_coyote_timer = 0
	player.change_state(player.State.JUMP)