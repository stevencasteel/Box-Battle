# src/entities/player/states/state_move.gd
# Handles the player's grounded movement state.
extends PlayerState

func enter():
	# MODIFIED: Get value from the new CombatDB resource.
	p_data.air_jumps_left = CombatDB.config.player_max_air_jumps
	p_data.can_dash = true

func process_physics(delta: float):
	# MODIFIED: Get value from the new CombatDB resource.
	p_data.coyote_timer = CombatDB.config.player_coyote_time
	
	player.velocity.y += CombatDB.config.gravity * delta
	player.apply_horizontal_movement()

	if not player.is_on_floor():
		player.change_state(player.State.FALL)
		return
	
	if Input.is_action_pressed("ui_down") and Input.is_action_just_pressed("ui_jump"):
		if player.get_last_slide_collision():
			var floor_collider = player.get_last_slide_collision().get_collider()
			if floor_collider and floor_collider.is_in_group("oneway_platforms"):
				player.position.y += 2
				p_data.jump_buffer_timer = 0
				player.change_state(player.State.FALL)
				return
	
	if p_data.jump_buffer_timer > 0:
		player.change_state(player.State.JUMP)
		return
