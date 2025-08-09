# src/entities/player/states/state_dash.gd
# Handles the player's dashing state.
extends PlayerState

func enter():
	# MODIFIED: All state variables now read from/write to p_data.
	p_data.is_dash_invincible = true
	p_data.can_dash = false
	p_data.dash_duration_timer = Config.get_value("player.physics.dash_duration")
	p_data.dash_cooldown_timer = Config.get_value("player.physics.dash_cooldown")
	player.velocity = _get_dash_direction() * Config.get_value("player.physics.dash_speed")

func exit():
	p_data.is_dash_invincible = false
	player.velocity = player.velocity * 0.5 

func process_physics(_delta: float):
	# MODIFIED: Check timer from p_data.
	if p_data.dash_duration_timer <= 0:
		player.change_state(player.State.FALL)

func _get_dash_direction():
	if Input.is_action_pressed("ui_up"): return Vector2.UP
	if Input.is_action_pressed("ui_down"): return Vector2.DOWN
	# MODIFIED: Read facing direction from p_data.
	return Vector2(p_data.facing_direction, 0)
