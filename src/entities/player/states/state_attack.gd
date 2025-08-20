# src/entities/player/states/state_attack.gd
## This state handles the player's melee and pogo attacks.
class_name PlayerStateAttack
extends BaseState

# --- State Lifecycle ---

func enter(_msg := {}) -> void:
	state_data.is_pogo_attack = owner.input_component.buffer.get("down", false)
	state_data.hit_targets_this_swing.clear()

	if state_data.is_pogo_attack:
		owner.enable_pogo_hitbox(true)
		# THE FIX: We no longer check immediately. The state will persist,
		# allowing the hitbox to remain active while falling.
	else:
		state_data.attack_duration_timer = state_data.config.player_attack_duration
		state_data.attack_cooldown_timer = state_data.config.player_attack_cooldown
		var is_up_attack = owner.input_component.buffer.get("up", false)
		owner.enable_melee_hitbox(true, is_up_attack)

func exit() -> void:
	owner.call_deferred("enable_melee_hitbox", false)
	owner.call_deferred("enable_pogo_hitbox", false)
	state_data.is_pogo_attack = false
	state_data.hit_targets_this_swing.clear()

func process_physics(delta: float) -> void:
	# THE FIX: If this is a pogo attack, just apply gravity. The collision
	# handlers in player.gd will trigger the exit from this state.
	if state_data.is_pogo_attack:
		owner.physics_component.apply_gravity(delta)
		# If we hit the ground, cancel the pogo.
		if owner.is_on_floor():
			state_machine.change_state(owner.State.MOVE)
		return
	
	# Original melee attack logic remains unchanged.
	var friction = state_data.config.player_attack_friction
	owner.velocity = owner.velocity.move_toward(Vector2.ZERO, friction * delta)

	if state_data.attack_duration_timer <= 0:
		state_machine.change_state(owner.State.FALL)
