# src/entities/player/states/state_heal.gd
# Handles the player's healing state.
extends PlayerState

func enter():
	player.velocity = Vector2.ZERO
	player.healing_timer.start(Constants.PLAYER_HEAL_DURATION)
	print("Healing started...")

func exit():
	player._cancel_heal()

func process_physics(_delta: float):
	# Cancel healing if conditions are broken (e.g., player moves or is no longer grounded)
	if not Input.is_action_pressed("ui_down") or not Input.is_action_pressed("ui_jump") or not is_zero_approx(player.velocity.x) or not player.is_on_floor():
		player.change_state(player.State.MOVE)
