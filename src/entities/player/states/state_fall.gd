# src/entities/player/states/state_fall.gd
## Handles the player's falling state (downward vertical movement).
extends BaseState

func process_physics(delta: float) -> void:
	owner.physics_component.apply_horizontal_movement()
	_apply_gravity(delta)

	if owner.is_on_floor():
		state_machine.change_state(owner.State.MOVE)
		return

	_check_for_wall_slide()

	if owner.input_component.buffer.get("jump_just_pressed"):
		if state_data.wall_coyote_timer > 0:
			_perform_wall_jump()
		elif state_data.coyote_timer > 0:
			state_machine.change_state(owner.State.JUMP)
		elif state_data.air_jumps_left > 0:
			_perform_air_jump()

func _apply_gravity(delta: float) -> void:
	var gravity_multiplier = 1.0
	if owner.input_component.buffer.get("down"):
		gravity_multiplier = state_data.config.player_fast_fall_gravity_multiplier
	owner.physics_component.apply_gravity(delta, gravity_multiplier)

func _check_for_wall_slide() -> void:
	var move_axis = owner.input_component.buffer.get("move_axis", 0.0)
	var can_wall_slide = state_data.wall_coyote_timer > 0 and \
		not owner.is_on_floor() and move_axis != 0 and \
		sign(move_axis) == -state_data.last_wall_normal.x
		
	if can_wall_slide:
		state_machine.change_state(owner.State.WALL_SLIDE)

func _perform_air_jump() -> void:
	# THE FIX: Pass a message to the JUMP state instead of decrementing here.
	state_machine.change_state(owner.State.JUMP, {"is_air_jump": true})

func _perform_wall_jump() -> void:
	owner.velocity.x = state_data.last_wall_normal.x * state_data.config.player_wall_jump_force_x
	state_data.coyote_timer = 0
	state_data.wall_coyote_timer = 0
	state_machine.change_state(owner.State.JUMP)