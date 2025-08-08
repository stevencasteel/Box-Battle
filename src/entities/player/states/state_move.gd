# src/entities/player/states/state_move.gd
# Handles the player's grounded movement state.
extends PlayerState

func enter():
	player.air_jumps_left = Config.get_value("player.physics.max_air_jumps")
	player.can_dash = true

func process_physics(delta: float):
	player.coyote_timer = Config.get_value("player.physics.coyote_time")
	
	player.velocity.y += Config.get_value("general.physics.gravity") * delta
	player.apply_horizontal_movement()

	if not player.is_on_floor():
		player.change_state(player.State.FALL)
		return
	
	if Input.is_action_pressed("ui_down") and Input.is_action_just_pressed("ui_jump"):
		if player.get_last_slide_collision():
			var floor_collider = player.get_last_slide_collision().get_collider()
			if floor_collider and floor_collider.is_in_group("oneway_platforms"):
				player.position.y += 2
				player.jump_buffer_timer = 0
				player.change_state(player.State.FALL)
				return
	
	if player.jump_buffer_timer > 0:
		player.change_state(player.State.JUMP)
		return
