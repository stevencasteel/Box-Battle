# src/entities/player/states/state_move.gd
## Handles the player's grounded movement state.
extends BaseState

# THE FIX: Preload the helper script to make its static methods available.
const JumpHelper = preload("res://src/entities/player/components/player_jump_helper.gd")

var _physics: PlayerPhysicsComponent
var _input: InputComponent


func enter(_msg := {}) -> void:
	_physics = owner.get_component(PlayerPhysicsComponent)
	_input = owner.get_component(InputComponent)
	state_data.air_jumps_left = state_data.config.player_max_air_jumps
	state_data.can_dash = true


func process_physics(delta: float) -> void:
	state_data.coyote_timer = state_data.config.player_coyote_time

	_physics.apply_gravity(delta)
	_physics.apply_horizontal_movement()

	if _input.buffer.get("jump_just_pressed"):
		var is_holding_down = _input.buffer.get("down", false)

		var can_try_heal = (
			is_holding_down and state_data.healing_charges > 0 and is_zero_approx(owner.velocity.x)
		)
		if can_try_heal:
			state_machine.change_state(Identifiers.PlayerStates.HEAL)
			return

		if is_holding_down:
			if JumpHelper.try_platform_drop(owner):
				return

		JumpHelper.try_jump(owner, state_data)
		return

	if not owner.is_on_floor():
		state_machine.change_state(Identifiers.PlayerStates.FALL)
		return