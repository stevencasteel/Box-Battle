# src/entities/player/states/state_attack.gd
## This state handles the player's melee and pogo attacks.
class_name PlayerStateAttack
extends BaseState

# --- State Lifecycle ---

func enter(_msg := {}) -> void:
	state_data.is_pogo_attack = owner.input_component.buffer.get("down", false)
	state_data.hit_targets_this_swing.clear()

	if state_data.is_pogo_attack:
		owner._enable_pogo_hitbox(true)
	else:
		state_data.attack_duration_timer = state_data.config.player_attack_duration
		state_data.attack_cooldown_timer = state_data.config.player_attack_cooldown
		var is_up_attack = owner.input_component.buffer.get("up", false)
		owner._enable_melee_hitbox(true, is_up_attack)

func exit() -> void:
	owner.call_deferred("_enable_melee_hitbox", false)
	owner.call_deferred("_enable_pogo_hitbox", false)
	state_data.is_pogo_attack = false
	state_data.hit_targets_this_swing.clear()

func process_physics(delta: float) -> void:
	if state_data.is_pogo_attack:
		owner.physics_component.apply_gravity(delta)
		if owner.is_on_floor():
			state_machine.change_state(owner.State.MOVE)
		return
	
	var friction = state_data.config.player_attack_friction
	owner.velocity = owner.velocity.move_toward(Vector2.ZERO, friction * delta)

	if state_data.attack_duration_timer <= 0:
		state_machine.change_state(owner.State.FALL)
