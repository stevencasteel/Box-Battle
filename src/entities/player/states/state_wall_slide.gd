# src/entities/player/states/state_wall_slide.gd
# Handles the player's wall sliding state.
extends PlayerState

func enter():
	p_data.can_dash = true
	# MODIFIED: Get value from the new CombatDB resource.
	p_data.air_jumps_left = CombatDB.config.player_max_air_jumps

func exit():
	if p_data.last_wall_normal != Vector2.ZERO:
		p_data.facing_direction = sign(p_data.last_wall_normal.x)

func process_physics(delta: float):
	# MODIFIED: Get values from the new CombatDB resource.
	var gravity = CombatDB.config.gravity
	var wall_slide_speed = CombatDB.config.player_wall_slide_speed
	player.velocity.y = min(player.velocity.y + gravity * delta, wall_slide_speed)
	
	p_data.facing_direction = sign(-p_data.last_wall_normal.x)
	
	if p_data.jump_buffer_timer > 0:
		_perform_wall_jump()
		return
	
	if Input.get_axis("ui_left", "ui_right") * -p_data.last_wall_normal.x < 0.8:
		player.change_state(player.State.FALL)
		return
		
	if p_data.wall_coyote_timer <= 0:
		player.change_state(player.State.FALL)
		return

	if player.is_on_floor():
		player.change_state(player.State.MOVE)
		return

func _perform_wall_jump():
	# MODIFIED: Get values from the new CombatDB resource.
	player.velocity.y = -CombatDB.config.player_wall_jump_force_y
	player.velocity.x = p_data.last_wall_normal.x * CombatDB.config.player_wall_jump_force_x
	p_data.jump_buffer_timer = 0
	p_data.coyote_timer = 0
	p_data.wall_coyote_timer = 0
	player.change_state(player.State.JUMP)
