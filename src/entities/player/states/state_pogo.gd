# src/entities/player/states/state_pogo.gd
## Handles the player's downward pogo attack state.
class_name PlayerStatePogo
extends BaseState

var _physics: PlayerPhysicsComponent

# --- State Lifecycle ---


func enter(_msg := {}) -> void:
	_physics = owner.get_component(PlayerPhysicsComponent)
	state_data.is_pogo_attack = true
	state_data.attack_duration_timer = state_data.config.player_attack_duration
	state_machine.pogo_hitbox_toggled.emit(true)


func exit() -> void:
	state_machine.pogo_hitbox_toggled.emit(false)
	state_data.is_pogo_attack = false


func process_physics(delta: float) -> void:
	_physics.apply_gravity(delta)

	if owner.is_on_floor():
		state_machine.change_state(Identifiers.PlayerStates.MOVE)
		return

	if state_data.attack_duration_timer <= 0:
		state_machine.change_state(Identifiers.PlayerStates.FALL)