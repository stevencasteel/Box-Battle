# src/entities/player/states/state_dash.gd
# Handles the player's dashing state.
extends PlayerState

func enter():
	# MODIFIED: Get values from the new CombatDB resource.
	p_data.is_dash_invincible = true
	p_data.can_dash = false
	p_data.dash_duration_timer = CombatDB.config.player_dash_duration
	p_data.dash_cooldown_timer = CombatDB.config.player_dash_cooldown
	player.velocity = _get_dash_direction() * CombatDB.config.player_dash_speed

func exit():
	p_data.is_dash_invincible = false
	player.velocity = player.velocity * 0.5 

func process_physics(_delta: float):
	if p_data.dash_duration_timer <= 0:
		player.change_state(player.State.FALL)

func _get_dash_direction():
	if Input.is_action_pressed("ui_up"): return Vector2.UP
	if Input.is_action_pressed("ui_down"): return Vector2.DOWN
	return Vector2(p_data.facing_direction, 0)
