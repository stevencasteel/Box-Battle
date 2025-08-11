# src/entities/player/states/state_move.gd
# Handles the player's grounded movement state.
extends BaseState

func enter(_msg := {}):
	state_data.air_jumps_left = CombatDB.config.player_max_air_jumps
	state_data.can_dash = true

func process_physics(delta: float):
	state_data.coyote_timer = CombatDB.config.player_coyote_time
	
	owner.velocity.y += CombatDB.config.gravity * delta
	owner.apply_horizontal_movement()

	if not owner.is_on_floor():
		state_machine.change_state(owner.State.FALL)
		return
	
	if Input.is_action_pressed("ui_down") and Input.is_action_just_pressed("ui_jump"):
		if owner.get_last_slide_collision():
			var floor_collider = owner.get_last_slide_collision().get_collider()
			if floor_collider and floor_collider.is_in_group("oneway_platforms"):
				owner.position.y += 2
				state_data.jump_buffer_timer = 0
				state_machine.change_state(owner.State.FALL)
				return
	
	if state_data.jump_buffer_timer > 0:
		state_machine.change_state(owner.State.JUMP)
		return
