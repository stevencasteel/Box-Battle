# src/entities/player/states/state_jump.gd
# Handles the player's upward movement (jump).
extends BaseState

func enter(_msg := {}):
	# THE FIX: Read directly from the injected config via the state_data resource.
	owner.velocity.y = -state_data.config.player_jump_force
	state_data.coyote_timer = 0
	state_data.jump_buffer_timer = 0

func process_physics(delta: float):
	owner.apply_horizontal_movement()
	
	# THE FIX: Read directly from the injected config.
	if Input.is_action_just_released("ui_jump") and owner.velocity.y < 0:
		owner.velocity.y *= state_data.config.player_jump_release_dampener

	_apply_gravity(delta)
	
	if owner.is_on_floor():
		state_machine.change_state(owner.State.MOVE)
		return

	_check_for_wall_slide()

func _apply_gravity(delta):
	# THE FIX: Read directly from the injected config.
	owner.velocity.y += state_data.config.gravity * delta
	if owner.velocity.y > 0.0:
		state_machine.change_state(owner.State.FALL)

func _check_for_wall_slide():
	if state_data.wall_coyote_timer > 0 and not owner.is_on_floor() and Input.get_axis("ui_left", "ui_right") != 0 and sign(Input.get_axis("ui_left", "ui_right")) == -state_data.last_wall_normal.x:
		state_machine.change_state(owner.State.WALL_SLIDE)