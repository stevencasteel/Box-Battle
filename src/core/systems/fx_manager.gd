# src/core/systems/fx_manager.gd
## An autoloaded singleton to handle purely aesthetic "game feel" effects.
##
## This separates feedback like hit-stop and screen shake from core gameplay
## logic, improving modularity and adhering to SRP.
extends Node

# --- Private Member Variables ---
var _is_hit_stop_active: bool = false
var _camera_shaker: CameraShaker = null

# --- Public Methods ---

## Stores a reference to the active CameraShaker in the scene.
func register_camera_shaker(shaker: CameraShaker) -> void:
	_camera_shaker = shaker

## Clears the reference to the CameraShaker when the scene changes.
func unregister_camera_shaker() -> void:
	_camera_shaker = null

## The main public API for triggering a screen shake effect.
func request_screen_shake(shake_effect: ScreenShakeEffect) -> void:
	if is_instance_valid(_camera_shaker):
		_camera_shaker.start_shake(shake_effect)
	else:
		push_warning("FXManager: request_screen_shake called, but no CameraShaker is registered.")

## Pauses the entire game tree for a short duration to add impact to an event.
func request_hit_stop(duration: float) -> void:
	# Prevent multiple hit-stops from overlapping, which can feel jarring.
	if _is_hit_stop_active:
		return

	_is_hit_stop_active = true
	get_tree().paused = true

	# Use a SceneTreeTimer that respects the pause state.
	var timer = get_tree().create_timer(duration, true, false, true)
	await timer.timeout

	# Check if the tree is still paused by the actual game menu before unpausing.
	if get_tree().paused and _is_hit_stop_active:
		get_tree().paused = false

	_is_hit_stop_active = false