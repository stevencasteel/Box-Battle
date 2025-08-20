# src/entities/player/states/state_heal.gd
# Handles the player's healing state.
extends BaseState

func enter(_msg := {}):
	owner.velocity = Vector2.ZERO
	owner.healing_timer.start(state_data.config.player_heal_duration)

func exit():
	owner._cancel_heal()

func process_physics(_delta: float):
	if not Input.is_action_pressed("ui_down") or not Input.is_action_pressed("ui_jump") or not is_zero_approx(owner.velocity.x) or not owner.is_on_floor():
		state_machine.change_state(owner.State.MOVE)