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

## The main public API for spawning a visual effect from the object pool.
func play_vfx(effect: VFXEffect, global_position: Vector2, direction: Vector2 = Vector2.ZERO) -> void:
	if not is_instance_valid(effect):
		push_warning("FXManager: play_vfx called with an invalid VFXEffect resource.")
		return

	if effect.pool_key == &"":
		push_warning("FXManager: VFXEffect resource is missing a 'pool_key'.")
		return

	var vfx_instance = ObjectPool.get_instance(effect.pool_key)
	if not is_instance_valid(vfx_instance):
		push_error("FXManager: Failed to get instance for pool key '%s'." % effect.pool_key)
		return

	vfx_instance.global_position = global_position

	if vfx_instance.has_method("activate"):
		vfx_instance.call("activate", direction)

## The main public API for triggering a shader-based effect.
func play_shader(effect: ShaderEffect, target_node: Node, _options: Dictionary = {}) -> void:
	if not is_instance_valid(effect) or not is_instance_valid(target_node):
		push_warning("FXManager.play_shader: Invalid effect or target node provided.")
		return

	match effect.target_scope:
		ShaderEffect.TargetScope.ENTITY:
			# This is now handled by FXComponent, so this can be a no-op or a warning.
			push_warning("FXManager.play_shader for ENTITY scope is deprecated. Use FXComponent.")
		ShaderEffect.TargetScope.UI:
			print("FXManager: Playing UI shader on ", target_node.name)
			# TODO: Implement UIShaderBinding logic
		ShaderEffect.TargetScope.FULLSCREEN:
			print("FXManager: Playing FULLSCREEN shader.")
			# TODO: Implement FullscreenShaderBinding logic
		_:
			push_error("FXManager: Unknown ShaderEffect.TargetScope.")

## Pauses the entire game tree for a short duration to add impact to an event.
func request_hit_stop(duration: float) -> void:
	if _is_hit_stop_active:
		return

	_is_hit_stop_active = true
	get_tree().paused = true

	var timer = get_tree().create_timer(duration, true, false, true)
	await timer.timeout

	if get_tree().paused and _is_hit_stop_active:
		get_tree().paused = false
		_is_hit_stop_active = false
