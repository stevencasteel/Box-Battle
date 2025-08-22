# src/core/systems/fx_manager.gd
## An autoloaded singleton to handle purely aesthetic "game feel" effects.
##
## This separates feedback like hit-stop and screen shake from core gameplay
## logic, improving modularity and adhering to SRP.
extends Node

# --- Private Member Variables ---
var _is_hit_stop_active: bool = false
var _camera_shaker: CameraShaker = null
var _effect_timestamps: Dictionary = {} # Tracks { entity_id: { effect_path: timestamp_msec } }

# --- Public Methods ---

## Stores a reference to the active CameraShaker in the scene.
func register_camera_shaker(shaker: CameraShaker) -> void:
	_camera_shaker = shaker

## Clears the reference to the CameraShaker when the scene changes.
func unregister_camera_shaker() -> void:
	_camera_shaker = null

## Checks if a valid CameraShaker is currently registered.
func is_camera_shaker_registered() -> bool:
	return is_instance_valid(_camera_shaker)

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

	# TODO: Implement effect coalescing.
	var target_id = target_node.get_instance_id()
	var effect_path = effect.resource_path

	if effect.coalesce_window > 0.0:
		var last_played_time = _effect_timestamps.get(target_id, {}).get(effect_path, 0)
		var current_time = Time.get_ticks_msec()
		if current_time - last_played_time < effect.coalesce_window * 1000:
			return # Coalesced: effect was played too recently on this target.
		
		if not _effect_timestamps.has(target_id):
			_effect_timestamps[target_id] = {}
		_effect_timestamps[target_id][effect_path] = current_time

	match effect.target_scope:
		# ENTITY scope is now handled directly by FXComponent.
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

## Pre-compiles a list of shaders by briefly rendering them off-screen.
func prewarm_shaders_async(effects: Array[ShaderEffect], prewarm_viewport: SubViewport) -> void:
	if not is_instance_valid(prewarm_viewport):
		push_error("FXManager: prewarm_shaders_async requires a valid SubViewport.")
		return
	
	print("FXManager: Starting shader pre-warm...")
	for effect in effects:
		if not is_instance_valid(effect) or not is_instance_valid(effect.material):
			continue
			
		var temp_rect = ColorRect.new()
		temp_rect.material = effect.material.duplicate(true)
		prewarm_viewport.add_child(temp_rect)
		
		# Wait one frame for the renderer to process and compile the shader.
		await get_tree().process_frame
		
		temp_rect.queue_free()
	print("FXManager: Shader pre-warm complete.")