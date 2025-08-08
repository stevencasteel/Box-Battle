# src/entities/player/states/state_dash.gd
# Handles the player's dashing state.
extends PlayerState

func enter():
	player.is_dash_invincible = true
	player.can_dash = false
	player.dash_duration_timer = Config.get_value("player.physics.dash_duration")
	player.dash_cooldown_timer = Config.get_value("player.physics.dash_cooldown")
	player.velocity = _get_dash_direction() * Config.get_value("player.physics.dash_speed")

func exit():
	player.is_dash_invincible = false
	player.velocity = player.velocity * 0.5 

func process_physics(_delta: float):
	if player.dash_duration_timer <= 0:
		player.change_state(player.State.FALL)

func _get_dash_direction():
	if Input.is_action_pressed("ui_up"): return Vector2.UP
	if Input.is_action_pressed("ui_down"): return Vector2.DOWN
	return Vector2(player.facing_direction, 0)
