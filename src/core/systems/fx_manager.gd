# src/core/systems/fx_manager.gd
## An autoloaded singleton to handle purely aesthetic "game feel" effects.
##
## This separates feedback like hit-stop and screen shake from core gameplay
## logic, improving modularity and adhering to SRP.
extends Node

# --- Private Member Variables ---
var _is_hit_stop_active: bool = false
var _camera_shaker: CameraShaker = null
var _services: ServiceLocator
var _managed_effects: Dictionary = {}

var _active_vfx_count: int = 0
var _active_shader_effects: int = 0


func _ready() -> void:
	_services = get_node("/root/ServiceLocator")


# --- Public Methods ---


func apply_shader_effect(
	target_node: CanvasItem, effect: ShaderEffect, overrides: Dictionary, opts: Dictionary
) -> Tween:
	if not is_instance_valid(target_node) or not is_instance_valid(effect):
		return null

	var target_id = target_node.get_instance_id()
	cancel_effect_on_node(target_node)

	var material_instance := effect.material.duplicate(true) as ShaderMaterial
	if not is_instance_valid(material_instance):
		push_error("FXManager: effect.material is not a ShaderMaterial.")
		return null

	if not overrides.is_empty():
		for param_name in overrides:
			material_instance.set_shader_parameter(param_name, overrides[param_name])
	
	_managed_effects[target_id] = {
		"original_material": target_node.material,
		"effect_material": material_instance
	}
	target_node.material = material_instance

	increment_shader_count()
	
	var tween = create_tween().set_parallel(false)
	tween.tween_property(
		material_instance, "shader_parameter/fx_progress", 1.0, effect.duration
	)
	
	var preserve_final_state = opts.get("preserve_final_state", false)
	tween.tween_callback(_on_shader_effect_finished.bind(target_node, preserve_final_state))
	_managed_effects[target_id]["active_tween"] = tween
	
	return tween


func cancel_effect_on_node(target_node: CanvasItem) -> void:
	if not is_instance_valid(target_node):
		return
	var target_id = target_node.get_instance_id()
	if _managed_effects.has(target_id):
		var effect_data = _managed_effects[target_id]
		if is_instance_valid(effect_data.active_tween):
			effect_data.active_tween.kill()
		_on_shader_effect_finished(target_node, false)


func increment_shader_count() -> void:
	_active_shader_effects += 1


func decrement_shader_count() -> void:
	_active_shader_effects -= 1


func register_camera_shaker(shaker: CameraShaker) -> void:
	_camera_shaker = shaker


func unregister_camera_shaker() -> void:
	_camera_shaker = null


func is_camera_shaker_registered() -> bool:
	return is_instance_valid(_camera_shaker)


func request_screen_shake(shake_effect: ScreenShakeEffect) -> void:
	if is_instance_valid(_camera_shaker):
		_camera_shaker.start_shake(shake_effect)
	else:
		push_warning("FXManager: request_screen_shake called, but no CameraShaker is registered.")


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
		var dependencies = {"services": _services, "direction": direction}
		vfx_instance.call("activate", dependencies)


func request_hit_stop(duration: float) -> void:
	if _is_hit_stop_active:
		return

	_is_hit_stop_active = true

	var affected_nodes: Array[Node]
	affected_nodes.append_array(get_tree().get_nodes_in_group(Identifiers.Groups.PLAYER))
	affected_nodes.append_array(get_tree().get_nodes_in_group(Identifiers.Groups.ENEMY))

	for node in affected_nodes:
		if is_instance_valid(node):
			node.set_deferred("process_mode", Node.PROCESS_MODE_DISABLED)

	var timer = get_tree().create_timer(duration, true, false, true)
	await timer.timeout

	if not get_tree():
		return

	for node in affected_nodes:
		if is_instance_valid(node):
			node.set_deferred("process_mode", Node.PROCESS_MODE_INHERIT)

	_is_hit_stop_active = false


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

		await get_tree().process_frame

		temp_rect.queue_free()
	print("FXManager: Shader pre-warm complete.")


func get_debug_stats() -> Dictionary:
	return {
		"active_vfx": _active_vfx_count,
		"active_shaders": _active_shader_effects,
	}

# --- Private Methods ---

func _on_shader_effect_finished(target_node: CanvasItem, preserve_final_state: bool) -> void:
	decrement_shader_count()
	
	if not is_instance_valid(target_node):
		return
		
	var target_id = target_node.get_instance_id()
	if not _managed_effects.has(target_id):
		return
		
	var effect_data = _managed_effects[target_id]
	var should_restore = not target_node.is_queued_for_deletion() and not preserve_final_state
	
	if should_restore:
		target_node.material = effect_data.original_material
		
	_managed_effects.erase(target_id)
