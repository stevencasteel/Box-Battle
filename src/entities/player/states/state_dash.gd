# src/entities/player/states/state_dash.gd
# Handles the player's dashing state.
extends BaseState

func enter(_msg := {}):
	state_data.is_dash_invincible = true
	state_data.can_dash = false
	state_data.dash_duration_timer = CombatDB.config.player_dash_duration
	state_data.dash_cooldown_timer = CombatDB.config.player_dash_cooldown
	owner.velocity = _get_dash_direction() * CombatDB.config.player_dash_speed

func exit():
	state_data.is_dash_invincible = false
	owner.velocity = owner.velocity * 0.5 

func process_physics(_delta: float):
	if state_data.dash_duration_timer <= 0:
		state_machine.change_state(owner.State.FALL)

func _get_dash_direction():
	if Input.is_action_pressed("ui_up"): return Vector2.UP
	if Input.is_action_pressed("ui_down"): return Vector2.DOWN
	return Vector2(state_data.facing_direction, 0)
