# src/entities/player/states/state_pogo.gd
## Handles the player's downward pogo attack state.
class_name PlayerStatePogo
extends BaseState

# --- State Lifecycle ---


func enter(_msg := {}) -> void:
	state_data.is_pogo_attack = true
	# Use the existing attack timer to give the pogo a limited duration.
	state_data.attack_duration_timer = state_data.config.player_attack_duration
	owner._enable_pogo_hitbox(true)


func exit() -> void:
	owner.call_deferred("_enable_pogo_hitbox", false)
	state_data.is_pogo_attack = false


func process_physics(delta: float) -> void:
	owner.physics_component.apply_gravity(delta)

	if owner.is_on_floor():
		state_machine.change_state(owner.State.MOVE)
		return

	if state_data.attack_duration_timer <= 0:
		state_machine.change_state(owner.State.FALL)
