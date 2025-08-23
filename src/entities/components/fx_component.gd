# src/entities/components/fx_component.gd
@tool
## A dedicated component for managing all entity-specific visual effects.
##
## CONTRACT: This component requires a "visual_node" dependency and will
## automatically discover a "HealthComponent" on its owner to trigger damage effects.
class_name FXComponent
extends IComponent

# --- Member Variables ---
var _owner: Node
var _visual_node: CanvasItem
var _health_component: HealthComponent
var _hit_effect: ShaderEffect  # Injected Dependency
var _original_material: Material
var _current_effect_name: String = "None"
var _active_tween: Tween
var _services: ServiceLocator


# --- Godot Lifecycle Methods ---
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		teardown()


func setup(p_owner: Node, p_dependencies: Dictionary = {}) -> void:
	self._owner = p_owner
	self._services = p_dependencies.get("services")
	assert(is_instance_valid(_services), "FXComponent requires a ServiceLocator.")

	assert(p_dependencies.has("visual_node"), "FXComponent requires a 'visual_node' dependency.")
	_visual_node = p_dependencies.get("visual_node")
	assert(
		is_instance_valid(_visual_node) and _visual_node is CanvasItem,
		"'visual_node' must be a valid CanvasItem."
	)

	_original_material = _visual_node.material

	# THE FIX: Automatically discover the HealthComponent on the owner.
	if _owner.has_method("get_component"):
		_health_component = _owner.get_component(HealthComponent)

	if is_instance_valid(_health_component):
		assert(
			p_dependencies.has("hit_effect"),
			"FXComponent requires a 'hit_effect' dependency when a HealthComponent is present."
		)
		_hit_effect = p_dependencies.get("hit_effect")
		assert(
			is_instance_valid(_hit_effect),
			"Injected 'hit_effect' must be a valid ShaderEffect resource."
		)
		# Guard against double-connect
		if not _health_component.took_damage.is_connected(_on_owner_took_damage):
			_health_component.took_damage.connect(_on_owner_took_damage)


func teardown() -> void:
	if is_instance_valid(_active_tween):
		_active_tween.kill()
		_active_tween = null

	if is_instance_valid(_health_component):
		if _health_component.took_damage.is_connected(_on_owner_took_damage):
			_health_component.took_damage.disconnect(_on_owner_took_damage)

	if is_instance_valid(_visual_node):
		_visual_node.material = _original_material

	_visual_node = null
	_owner = null
	_health_component = null
	_services = null


# --- Public API ---


func play_effect(effect: ShaderEffect, overrides: Dictionary = {}, opts: Dictionary = {}) -> Tween:
	if not is_instance_valid(effect) or not is_instance_valid(effect.material):
		push_error("FXComponent: play_effect called with an invalid effect or material.")
		return null

	if is_instance_valid(_active_tween):
		_active_tween.kill()

	_current_effect_name = effect.resource_path.get_file()

	# CORE FIX: Always duplicate the material to prevent shared state bugs.
	var material_instance := effect.material.duplicate(true) as ShaderMaterial
	if not is_instance_valid(material_instance):
		push_error("FXComponent: effect.material is not a ShaderMaterial.")
		return null

	# Apply runtime parameter overrides if any were provided.
	if not overrides.is_empty():
		for param_name in overrides:
			material_instance.set_shader_parameter(param_name, overrides[param_name])

	_visual_node.material = material_instance

	# Report the effect start to the central manager.
	_services.fx_manager.increment_shader_count()

	_active_tween = create_tween().set_parallel(false)
	_active_tween.tween_property(
		material_instance, "shader_parameter/fx_progress", 1.0, effect.duration
	)

	# The final step in the tween is to call the cleanup function.
	# This ensures cleanup happens even if the tween is killed.
	_active_tween.tween_callback(_on_effect_finished.bind(opts.get("preserve_final_state", false)))

	return _active_tween


## Returns the filename of the currently playing effect.
func get_current_effect_name() -> String:
	return _current_effect_name


# --- Signal Handlers ---


func _on_owner_took_damage(_damage_info: DamageInfo, _damage_result: DamageResult) -> void:
	if is_instance_valid(_hit_effect):
		play_effect(_hit_effect, {})
	else:
		push_warning(
			(
				"FXComponent on '%s' received took_damage, but has no default_hit_effect assigned."
				% [_owner.name]
			)
		)


func _on_effect_finished(preserve_final_state: bool) -> void:
	# Report the effect end to the central manager.
	if is_instance_valid(_services):
		_services.fx_manager.decrement_shader_count()
	
	# Ensure the owner is still valid before trying to access it.
	if not is_instance_valid(_owner):
		return

	# Do not restore the original material if the owner is being deleted
	# or if the effect is meant to be permanent (like a dissolve).
	var should_restore := not _owner.is_queued_for_deletion() and not preserve_final_state

	if is_instance_valid(_visual_node) and should_restore:
		_visual_node.material = _original_material

	_current_effect_name = "None"
	_active_tween = null