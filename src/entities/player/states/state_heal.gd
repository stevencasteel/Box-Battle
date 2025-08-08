# src/entities/player/states/state_heal.gd
# Handles the player's healing state.
extends PlayerState

func enter():
	player.velocity = Vector2.ZERO
	player.healing_timer.start(Config.get_value("player.health.heal_duration"))
	print("Healing started...")

func exit():
	player._cancel_heal()

func process_physics(_delta: float):
	if not Input.is_action_pressed("ui_down") or not Input.is_action_pressed("ui_jump") or not is_zero_approx(player.velocity.x) or not player.is_on_floor():
		player.change_state(player.State.MOVE)
