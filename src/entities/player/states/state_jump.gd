# src/entities/player/states/state_jump.gd
# Handles the player's upward movement (jump).
extends PlayerState

func enter():
	# MODIFIED: Get value from the new CombatDB resource.
	player.velocity.y = -CombatDB.config.player_jump_force
	p_data.coyote_timer = 0
	p_data.jump_buffer_timer = 0

func process_physics(delta: float):
	player.apply_horizontal_movement()
	
	# MODIFIED: Get value from the new CombatDB resource.
	if Input.is_action_just_released("ui_jump") and player.velocity.y < 0:
		player.velocity.y *= CombatDB.config.player_jump_release_dampener

	_apply_gravity(delta)
	
	if player.is_on_floor():
		player.change_state(player.State.MOVE)
		return

	_check_for_wall_slide()

func _apply_gravity(delta):
	# MODIFIED: Get value from the new CombatDB resource.
	player.velocity.y += CombatDB.config.gravity * delta
	if player.velocity.y > 0.0:
		player.change_state(player.State.FALL)

func _check_for_wall_slide():
	if p_data.wall_coyote_timer > 0 and not player.is_on_floor() and Input.get_axis("ui_left", "ui_right") != 0 and sign(Input.get_axis("ui_left", "ui_right")) == -p_data.last_wall_normal.x:
		player.change_state(player.State.WALL_SLIDE)
