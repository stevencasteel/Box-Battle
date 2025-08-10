# src/entities/player/states/state_fall.gd
# Handles the player's falling state.
extends PlayerState

func process_physics(delta: float):
	player.apply_horizontal_movement()
	_apply_gravity(delta)

	if player.is_on_floor():
		player.change_state(player.State.MOVE)
		return

	_check_for_wall_slide()

	if p_data.jump_buffer_timer > 0:
		if p_data.wall_coyote_timer > 0:
			_perform_wall_jump()
		elif p_data.coyote_timer > 0:
			player.change_state(player.State.JUMP)
		elif p_data.air_jumps_left > 0:
			_perform_air_jump()

func _apply_gravity(delta):
	var gravity_multiplier = 1.0
	# MODIFIED: Get value from the new CombatDB resource.
	if Input.is_action_pressed("ui_down"):
		gravity_multiplier = CombatDB.config.player_fast_fall_gravity_multiplier
	player.velocity.y += CombatDB.config.gravity * gravity_multiplier * delta

func _check_for_wall_slide():
	if p_data.wall_coyote_timer > 0 and not player.is_on_floor() and Input.get_axis("ui_left", "ui_right") != 0 and sign(Input.get_axis("ui_left", "ui_right")) == -p_data.last_wall_normal.x:
		player.change_state(player.State.WALL_SLIDE)

func _perform_air_jump():
	p_data.air_jumps_left -= 1
	player.change_state(player.State.JUMP)
	
func _perform_wall_jump():
	# MODIFIED: Get value from the new CombatDB resource.
	player.velocity.x = p_data.last_wall_normal.x * CombatDB.config.player_wall_jump_force_x
	p_data.coyote_timer = 0
	p_data.wall_coyote_timer = 0
	player.change_state(player.State.JUMP)
