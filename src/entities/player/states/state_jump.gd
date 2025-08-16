# src/entities/player/states/state_jump.gd
## Handles the player's upward movement (jump).
extends BaseState

func enter(_msg := {}) -> void:
	owner.velocity.y = -state_data.config.player_jump_force
	state_data.coyote_timer = 0

func process_physics(delta: float) -> void:
	owner.physics_component.apply_horizontal_movement()

	if owner.input_component.buffer.get("jump_released") and owner.velocity.y < 0:
		owner.velocity.y *= state_data.config.player_jump_release_dampener

	_apply_gravity(delta)

	if owner.is_on_floor():
		state_machine.change_state(owner.State.MOVE)
		return

	_check_for_wall_slide()

func _apply_gravity(delta: float) -> void:
	owner.physics_component.apply_gravity(delta)
	if owner.velocity.y > 0.0:
		state_machine.change_state(owner.State.FALL)

func _check_for_wall_slide() -> void:
	var move_axis = owner.input_component.buffer.get("move_axis", 0.0)
	var can_wall_slide = state_data.wall_coyote_timer > 0 and \
		not owner.is_on_floor() and move_axis != 0 and \
		sign(move_axis) == -state_data.last_wall_normal.x
		
	if can_wall_slide:
		state_machine.change_state(owner.State.WALL_SLIDE)