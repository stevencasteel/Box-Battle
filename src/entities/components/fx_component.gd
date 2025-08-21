# src/entities/components/fx_component.gd
@tool
## A dedicated component for managing all entity-specific visual effects.
##
## CONTRACT: This component requires a "visual_node" dependency and optionally
## accepts a "health_component" to auto-trigger damage effects.
class_name FXComponent
extends IComponent

# --- Editor Properties ---
## An optional, default effect to play on damage. Can be overridden by dependencies.
@export var default_hit_effect: ShaderEffect

# --- Member Variables ---
var _owner: Node
var _visual_node: CanvasItem
var _health_component: HealthComponent
var _original_material: Material
var _active_tween: Tween
var _current_effect_name: String = "None"

# A proxy property for the tween to animate.
var _progress: float = 0.0:
	set(value):
		_progress = value
		if is_instance_valid(_visual_node) and is_instance_valid(_visual_node.material):
			(_visual_node.material as ShaderMaterial).set_shader_parameter("fx_progress", _progress)

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
		_health_component.took_damage.connect(_on_owner_took_damage)

	var injected_effect = p_dependencies.get("hit_effect", null)
	if is_instance_valid(injected_effect):
		default_hit_effect = injected_effect

func teardown() -> void:
	if is_instance_valid(_active_tween):
		_active_tween.kill()

	if is_instance_valid(_health_component) and _health_component.took_damage.is_connected(_on_owner_took_damage):
		_health_component.took_damage.disconnect(_on_owner_took_damage)

	if is_instance_valid(_visual_node):
		_visual_node.material = _original_material

	_visual_node = null
	_owner = null
	_health_component = null

# --- Public API ---

## Plays a configured ShaderEffect resource on the visual_node.
func play_effect(effect: ShaderEffect) -> void:
	if not is_instance_valid(effect) or not is_instance_valid(effect.material):
		push_error("FXComponent: play_effect called with an invalid effect or material.")
		return
		
	if is_instance_valid(_active_tween):
		_active_tween.kill()
		
	_current_effect_name = effect.resource_path.get_file()

	var material_instance = effect.material.duplicate(true)
	_visual_node.material = material_instance
	
	self._progress = 0.0
	
	_active_tween = create_tween()
	_active_tween.tween_property(self, "_progress", 1.0, effect.duration)
	_active_tween.finished.connect(_on_effect_finished)

## Returns the filename of the currently playing effect.
func get_current_effect_name() -> String:
	return _current_effect_name

# --- Signal Handlers ---

func _on_owner_took_damage(_damage_info: DamageInfo, _damage_result: DamageResult) -> void:
	if is_instance_valid(default_hit_effect):
		play_effect(default_hit_effect)
	else:
		push_warning("FXComponent on '%s' received took_damage, but has no default_hit_effect assigned." % [_owner.name])

func _on_effect_finished() -> void:
	if is_instance_valid(_visual_node):
		_visual_node.material = _original_material
	_active_tween = null
	_current_effect_name = "None"