# src/entities/player/states/state_jump.gd
## Handles the player's upward movement (jump).
extends BaseState


func enter(msg := {}) -> void:
	if msg.get("is_air_jump", false):
		state_data.air_jumps_left -= 1

	owner.velocity.y = -state_data.config.player_jump_force
	state_data.coyote_timer = 0


func process_physics(delta: float) -> void:
	owner.physics_component.apply_horizontal_movement()

	if owner.input_component.buffer.get("jump_just_pressed"):
		if state_data.air_jumps_left > 0:
			_perform_air_jump()

	if owner.input_component.buffer.get("jump_released") and owner.velocity.y < 0:
		owner.velocity.y *= state_data.config.player_jump_release_dampener

	_apply_gravity(delta)

	if owner.is_on_floor():
		state_machine.change_state(owner.State.MOVE)
		return

	if owner.physics_component.can_wall_slide():
		state_machine.change_state(owner.State.WALL_SLIDE)
		return


func _apply_gravity(delta: float) -> void:
	owner.physics_component.apply_gravity(delta)
	if owner.velocity.y > 0.0:
		state_machine.change_state(owner.State.FALL)


func _perform_air_jump() -> void:
	state_data.air_jumps_left -= 1
	owner.velocity.y = -state_data.config.player_jump_force