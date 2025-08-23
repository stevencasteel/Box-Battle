# src/entities/player/states/state_attack.gd
## This state handles the player's melee attack.
class_name PlayerStateAttack
extends BaseState

var _input: InputComponent

# --- State Lifecycle ---


func enter(_msg := {}) -> void:
	_input = owner.get_component(InputComponent)
	state_data.hit_targets_this_swing.clear()
	state_data.attack_duration_timer = state_data.config.player_attack_duration
	state_data.attack_cooldown_timer = state_data.config.player_attack_cooldown
	var is_up_attack = _input.buffer.get("up", false)
	state_machine.melee_hitbox_toggled.emit(true, is_up_attack)


func exit() -> void:
	state_machine.melee_hitbox_toggled.emit(false, false)
	state_data.hit_targets_this_swing.clear()


func process_physics(delta: float) -> void:
	var friction = state_data.config.player_attack_friction
	owner.velocity = owner.velocity.move_toward(Vector2.ZERO, friction * delta)

	if state_data.attack_duration_timer <= 0:
		state_machine.change_state(Identifiers.PlayerStates.FALL)