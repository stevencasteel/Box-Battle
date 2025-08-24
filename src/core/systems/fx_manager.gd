# src/core/systems/fx_manager.gd
## An autoloaded singleton to handle purely aesthetic "game feel" effects.
##
## This separates feedback like hit-stop and screen shake from core gameplay
## logic, improving modularity and adhering to SRP.
extends Node

# --- Private Member Variables ---
var _is_hit_stop_active: bool = false
var _camera_shaker: CameraShaker = null

var _active_vfx_count: int = 0
var _active_shader_effects: int = 0

# --- Public Methods ---


## Increments the active shader counter. Called by external systems like FXComponent.
func increment_shader_count() -> void:
	_active_shader_effects += 1


## Decrements the active shader counter. Called by external systems like FXComponent.
func decrement_shader_count() -> void:
	_active_shader_effects -= 1


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
func play_vfx(
	effect: VFXEffect, global_position: Vector2, direction: Vector2 = Vector2.ZERO
) -> void:
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

	_active_vfx_count += 1
	vfx_instance.tree_exited.connect(func(): _active_vfx_count -= 1, CONNECT_ONE_SHOT)

	vfx_instance.global_position = global_position

	if vfx_instance.has_method("activate"):
		vfx_instance.call("activate", direction)


## Pauses specific gameplay nodes for a short duration to add impact to an event.
func request_hit_stop(duration: float) -> void:
	if _is_hit_stop_active:
		return

	_is_hit_stop_active = true

	# 1. Find all nodes that should be affected by hit-stop.
	var affected_nodes: Array[Node]
	affected_nodes.append_array(get_tree().get_nodes_in_group(Identifiers.Groups.PLAYER))
	affected_nodes.append_array(get_tree().get_nodes_in_group(Identifiers.Groups.ENEMY))

	# 2. Pause the nodes using call_deferred to avoid physics engine errors.
	for node in affected_nodes:
		if is_instance_valid(node):
			node.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)

	# 3. Create a timer that is not affected by time scale.
	var timer = get_tree().create_timer(duration, true, false, true)
	await timer.timeout

	# 4. Resume the nodes. Guard against scene changes during the await.
	if not get_tree():
		return

	for node in affected_nodes:
		if is_instance_valid(node):
			node.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)

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


## Returns a dictionary of current FX stats for debugging purposes.
func get_debug_stats() -> Dictionary:
	return {
		"active_vfx": _active_vfx_count,
		"active_shaders": _active_shader_effects,
	}
