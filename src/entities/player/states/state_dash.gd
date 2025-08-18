# src/entities/player/states/state_dash.gd
extends BaseState

var _dash_direction: Vector2
var _invincibility_token: int

func enter(_msg := {}):
	state_data.can_dash = false
	state_data.dash_duration_timer = state_data.config.player_dash_duration
	state_data.dash_cooldown_timer = state_data.config.player_dash_cooldown
	
	_invincibility_token = owner.health_component.grant_invincibility(self)
	
	_dash_direction = _get_dash_direction()
	owner.velocity = _dash_direction * state_data.config.player_dash_speed

func exit():
	if is_instance_valid(owner) and is_instance_valid(owner.health_component):
		owner.health_component.release_invincibility(_invincibility_token)
	
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