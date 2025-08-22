# src/entities/components/fx_component.gd
@tool
## A dedicated component for managing all entity-specific visual effects.
##
## CONTRACT: This component requires a "visual_node" dependency and optionally
## accepts a "health_component" to auto-trigger damage effects.
class_name FXComponent
extends IComponent

# --- Member Variables ---
var _owner: Node
var _visual_node: CanvasItem
var _health_component: HealthComponent
var _hit_effect: ShaderEffect # Injected Dependency
var _original_material: Material
var _current_effect_name: String = "None"

var _active_tween: Tween
var _material_instance: ShaderMaterial

# --- Private Member Variables ---
var _shader_uniform_cache: Dictionary = {}
var _preserve_material_on_finish: bool = false

# A proxy property for the tween to animate.
var _progress: float = 0.0:
	set(value):
		_progress = value
		if is_instance_valid(_material_instance):
			_material_instance.set_shader_parameter("fx_progress", _progress)

# --- Godot Lifecycle Methods ---
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		teardown()

func setup(p_owner: Node, p_dependencies: Dictionary = {}) -> void:
	self._owner = p_owner
	
	assert(p_dependencies.has("visual_node"), "FXComponent requires a 'visual_node' dependency.")
	_visual_node = p_dependencies.get("visual_node")
	assert(is_instance_valid(_visual_node) and _visual_node is CanvasItem, "'visual_node' must be a valid CanvasItem.")
	
	_original_material = _visual_node.material

	_health_component = p_dependencies.get("health_component", null)
	if is_instance_valid(_health_component):
		assert(p_dependencies.has("hit_effect"), "FXComponent requires a 'hit_effect' dependency when a HealthComponent is present.")
		_hit_effect = p_dependencies.get("hit_effect")
		assert(is_instance_valid(_hit_effect), "Injected 'hit_effect' must be a valid ShaderEffect resource.")
		_health_component.took_damage.connect(_on_owner_took_damage)

	if is_instance_valid(_original_material) and _original_material is ShaderMaterial:
		_material_instance = _original_material.duplicate(true) as ShaderMaterial
	else:
		_material_instance = ShaderMaterial.new()

func teardown() -> void:
	if is_instance_valid(_active_tween):
		_active_tween.kill()
		_active_tween = null

	if is_instance_valid(_health_component) and _health_component.took_damage.is_connected(_on_owner_took_damage):
		_health_component.took_damage.disconnect(_on_owner_took_damage)

	if is_instance_valid(_visual_node):
		var owner_allows_restore := true
		if is_instance_valid(_owner) and _owner.has_method("is_queued_for_deletion") and _owner.is_queued_for_deletion():
			owner_allows_restore = false
		if owner_allows_restore and not _preserve_material_on_finish:
			_visual_node.material = _original_material

	_visual_node = null
	_owner = null
	_health_component = null
	_material_instance = null
	_preserve_material_on_finish = false

# --- Public API ---

func play_effect(effect: ShaderEffect, overrides: Dictionary = {}, opts: Dictionary = {}) -> Tween:
	if not is_instance_valid(effect) or not is_instance_valid(effect.material):
		push_error("FXComponent: play_effect called with an invalid effect or material.")
		return null
		
	if is_instance_valid(_active_tween):
		_active_tween.kill()
	
	_current_effect_name = effect.resource_path.get_file()
	_preserve_material_on_finish = opts.get("preserve_final_state", false)

	var src_material := effect.material as ShaderMaterial
	if not is_instance_valid(src_material):
		push_error("FXComponent: effect.material is not a ShaderMaterial.")
		return null

	var shader_res := src_material.shader
	_material_instance.shader = shader_res

	if is_instance_valid(shader_res):
		var uniform_list: Array
		if _shader_uniform_cache.has(shader_res):
			uniform_list = _shader_uniform_cache[shader_res]
		else:
			uniform_list = shader_res.get_shader_uniform_list()
			_shader_uniform_cache[shader_res] = uniform_list

		for param_info in uniform_list:
			var param_name: String = param_info.get("name", "")
			var usage := int(param_info.get("usage", 0))
			
			var is_sampler = not (usage & PROPERTY_USAGE_DEFAULT)
			if not is_sampler and param_name != "fx_progress" and param_name != "":
				var value = src_material.get_shader_parameter(param_name)
				_material_instance.set_shader_parameter(param_name, value)
		
		if not overrides.is_empty():
			for param_name in overrides:
				_material_instance.set_shader_parameter(param_name, overrides[param_name])
	
	_visual_node.material = _material_instance
	self._progress = 0.0
	
	_active_tween = create_tween()
	_active_tween.finished.connect(_on_effect_finished, CONNECT_ONE_SHOT)
	_active_tween.tween_property(self, "_progress", 1.0, effect.duration)
	return _active_tween

## Returns the filename of the currently playing effect.
func get_current_effect_name() -> String:
	return _current_effect_name

# --- Signal Handlers ---

func _on_owner_took_damage(_damage_info: DamageInfo, _damage_result: DamageResult) -> void:
	if is_instance_valid(_hit_effect):
		play_effect(_hit_effect, {})
	else:
		push_warning("FXComponent on '%s' received took_damage, but has no default_hit_effect assigned." % [_owner.name])

func _on_effect_finished() -> void:
	var do_restore := true
	if is_instance_valid(_owner) and _owner.has_method("is_queued_for_deletion") and _owner.is_queued_for_deletion():
		do_restore = false
	if _preserve_material_on_finish:
		do_restore = false

	if is_instance_valid(_visual_node) and do_restore:
		_visual_node.material = _original_material

	_current_effect_name = "None"
	_active_tween = null
	_preserve_material_on_finish = false
