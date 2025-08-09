# src/entities/player/states/state_jump.gd
# Handles the player's upward movement (jump).
extends PlayerState

func enter():
	player.velocity.y = -Config.get_value("player.physics.jump_force")
	# MODIFIED: Reset timers in the p_data resource.
	p_data.coyote_timer = 0
	p_data.jump_buffer_timer = 0

func process_physics(delta: float):
	player.apply_horizontal_movement()
	
	if Input.is_action_just_released("ui_jump") and player.velocity.y < 0:
		player.velocity.y *= Config.get_value("player.physics.jump_release_dampener")

	_apply_gravity(delta)
	
	if player.is_on_floor():
		player.change_state(player.State.MOVE)
		return

	_check_for_wall_slide()

func _apply_gravity(delta):
	player.velocity.y += Config.get_value("general.physics.gravity") * delta
	if player.velocity.y > 0.0:
		player.change_state(player.State.FALL)

func _check_for_wall_slide():
	# MODIFIED: All state variables now read from/write to p_data.
	if p_data.wall_coyote_timer > 0 and not player.is_on_floor() and Input.get_axis("ui_left", "ui_right") != 0 and sign(Input.get_axis("ui_left", "ui_right")) == -p_data.last_wall_normal.x:
		player.change_state(player.State.WALL_SLIDE)
