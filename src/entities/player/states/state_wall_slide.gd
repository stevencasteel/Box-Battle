# src/entities/player/states/state_wall_slide.gd
# Handles the player's wall sliding state.
extends BaseState

func enter(_msg := {}):
	state_data.can_dash = true
	# THE FIX: Read directly from the unified CombatDB.
	state_data.air_jumps_left = CombatDB.config.player_max_air_jumps

func exit():
	if state_data.last_wall_normal != Vector2.ZERO:
		state_data.facing_direction = sign(state_data.last_wall_normal.x)

func process_physics(delta: float):
	# THE FIX: Read all values directly from the unified CombatDB.
	var gravity = CombatDB.config.gravity
	var wall_slide_speed = CombatDB.config.player_wall_slide_speed
	owner.velocity.y = min(owner.velocity.y + gravity * delta, wall_slide_speed)
	
	state_data.facing_direction = sign(-state_data.last_wall_normal.x)
	
	if state_data.jump_buffer_timer > 0:
		_perform_wall_jump()
		return
	
	if Input.get_axis("ui_left", "ui_right") * -state_data.last_wall_normal.x < 0.8:
		state_machine.change_state(owner.State.FALL)
		return
		
	if state_data.wall_coyote_timer <= 0:
		state_machine.change_state(owner.State.FALL)
		return

	if owner.is_on_floor():
		state_machine.change_state(owner.State.MOVE)
		return

func _perform_wall_jump():
	# THE FIX: Read directly from the unified CombatDB.
	owner.velocity.y = -CombatDB.config.player_wall_jump_force_y
	owner.velocity.x = state_data.last_wall_normal.x * CombatDB.config.player_wall_jump_force_x
	state_data.jump_buffer_timer = 0
	state_data.coyote_timer = 0
	state_data.wall_coyote_timer = 0
	state_machine.change_state(owner.State.JUMP)