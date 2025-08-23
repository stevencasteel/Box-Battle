# src/entities/player/states/state_fall.gd
## Handles the player's falling state (downward vertical movement).
extends BaseState

var _physics: PlayerPhysicsComponent
var _input: InputComponent


func enter(_msg := {}) -> void:
	_physics = owner.get_component(PlayerPhysicsComponent)
	_input = owner.get_component(InputComponent)


func process_physics(delta: float) -> void:
	_physics.apply_horizontal_movement()
	_apply_gravity(delta)

	if owner.is_on_floor():
		state_machine.change_state(owner.State.MOVE)
		return

	if _physics.can_wall_slide():
		state_machine.change_state(owner.State.WALL_SLIDE)
		return

	if _input.buffer.get("jump_just_pressed"):
		if state_data.wall_coyote_timer > 0:
			_physics.perform_wall_jump()
			state_machine.change_state(owner.State.JUMP)
		elif state_data.coyote_timer > 0:
			state_machine.change_state(owner.State.JUMP)
		elif state_data.air_jumps_left > 0:
			state_machine.change_state(owner.State.JUMP, {"is_air_jump": true})


func _apply_gravity(delta: float) -> void:
	var gravity_multiplier = 1.0
	if _input.buffer.get("down"):
		gravity_multiplier = state_data.config.player_fast_fall_gravity_multiplier
	_physics.apply_gravity(delta, gravity_multiplier)