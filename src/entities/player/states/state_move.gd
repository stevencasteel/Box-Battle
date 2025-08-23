# src/entities/player/states/state_move.gd
## Handles the player's grounded movement state.
extends BaseState

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

		# 1. Check for Heal (Highest priority on jump press)
		var can_try_heal = (
			is_holding_down and state_data.healing_charges > 0 and is_zero_approx(owner.velocity.x)
		)
		if can_try_heal:
			state_machine.change_state(owner.State.HEAL)
			return

		# 2. Check for Drop-through Platform
		if is_holding_down:
			var floor_col = owner.get_last_slide_collision()
			if floor_col:
				var floor_collider = floor_col.get_collider()
				if (
					is_instance_valid(floor_collider)
					and floor_collider.is_in_group(Identifiers.Groups.ONEWAY_PLATFORMS)
				):
					owner.position.y += 2
					state_machine.change_state(owner.State.FALL)
					return

		# 3. If neither of the above, it's a regular jump
		state_machine.change_state(owner.State.JUMP)
		return

	if not owner.is_on_floor():
		state_machine.change_state(owner.State.FALL)
		return