# src/entities/player/states/state_dash.gd
# EXPERIMENTAL: All momentum is now cancelled at the end of a dash
# to test the "hard stop" game feel.
extends BaseState

var _dash_direction: Vector2

func enter(_msg := {}):
	state_data.is_dash_invincible = true
	state_data.can_dash = false
	# THE FIX: Read all values directly from the unified CombatDB.
	state_data.dash_duration_timer = CombatDB.config.player_dash_duration
	state_data.dash_cooldown_timer = CombatDB.config.player_dash_cooldown
	
	_dash_direction = _get_dash_direction()
	owner.velocity = _dash_direction * CombatDB.config.player_dash_speed

func exit():
	state_data.is_dash_invincible = false
	
	if _dash_direction.y != 0:
		owner.velocity.y = 0.0
	if _dash_direction.x != 0:
		owner.velocity.x = 0.0

func process_physics(_delta: float):
	if state_data.dash_duration_timer <= 0:
		state_machine.change_state(owner.State.FALL)

func _get_dash_direction():
	if Input.is_action_pressed("ui_up"): return Vector2.UP
	if Input.is_action_pressed("ui_down"): return Vector2.DOWN
	return Vector2(state_data.facing_direction, 0)