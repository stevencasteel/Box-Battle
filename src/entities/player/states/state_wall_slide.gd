# src/entities/player/states/state_wall_slide.gd
# Handles the player's wall sliding state.
extends PlayerState

func enter():
	player.can_dash = true
	player.air_jumps_left = Config.get_value("player.physics.max_air_jumps")

func exit():
	if player.last_wall_normal != Vector2.ZERO:
		player.facing_direction = player.last_wall_normal.x

func process_physics(delta: float):
	var gravity = Config.get_value("general.physics.gravity")
	var wall_slide_speed = Config.get_value("player.physics.wall_slide_speed")
	player.velocity.y = min(player.velocity.y + gravity * delta, wall_slide_speed)
	player.facing_direction = -player.last_wall_normal.x
	
	if player.jump_buffer_timer > 0:
		_perform_wall_jump()
		return
	
	if Input.get_axis("ui_left", "ui_right") * -player.last_wall_normal.x < 0.8:
		player.change_state(player.State.FALL)
		return
		
	if player.wall_coyote_timer <= 0:
		player.change_state(player.State.FALL)
		return

	if player.is_on_floor():
		player.change_state(player.State.MOVE)
		return

func _perform_wall_jump():
	player.velocity.y = -Config.get_value("player.physics.wall_jump_force_y")
	player.velocity.x = player.last_wall_normal.x * Config.get_value("player.physics.wall_jump_force_x")
	player.jump_buffer_timer = 0
	player.coyote_timer = 0
	player.wall_coyote_timer = 0
	player.change_state(player.State.JUMP)