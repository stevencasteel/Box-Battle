# src/entities/player/states/state_move.gd
# Handles the player's grounded movement state.
extends PlayerState

func enter():
	player.air_jumps_left = Constants.MAX_AIR_JUMPS
	player.can_dash = true

func process_physics(delta: float):
	player.coyote_timer = Constants.COYOTE_TIME
	
	player.velocity.y += Constants.GRAVITY * delta
	# REFINEMENT: Call the centralized movement function.
	player.apply_horizontal_movement()

	if not player.is_on_floor():
		# REFINEMENT: Use global enum syntax for clarity.
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
