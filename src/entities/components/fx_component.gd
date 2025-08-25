# src/entities/components/fx_component.gd
@tool
## A dedicated component for managing all entity-specific visual effects.
##
## CONTRACT: This component requires a "visual_node" and an "fx_manager" dependency.
## It will automatically discover a "HealthComponent" on its owner to trigger damage effects.
class_name FXComponent
extends IComponent

# --- Member Variables ---
var _owner: Node
var _visual_node: CanvasItem
var _health_component: HealthComponent
var _hit_effect: ShaderEffect  # Injected Dependency
var _fx_manager: IFXManager   # Holds a direct reference to the service.

# --- Godot Lifecycle Methods ---
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		teardown()

func setup(p_owner: Node, p_dependencies: Dictionary = {}) -> void:
	self._owner = p_owner
	
	assert(p_dependencies.has("fx_manager"), "FXComponent requires an 'fx_manager' dependency.")
	self._fx_manager = p_dependencies.get("fx_manager")
	assert(is_instance_valid(_fx_manager), "Injected 'fx_manager' must be a valid IFXManager.")

	assert(p_dependencies.has("visual_node"), "FXComponent requires a 'visual_node' dependency.")
	_visual_node = p_dependencies.get("visual_node")
	assert(
		is_instance_valid(_visual_node) and _visual_node is CanvasItem,
		"'visual_node' must be a valid CanvasItem."
	)

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
		if not _health_component.took_damage.is_connected(_on_owner_took_damage):
			_health_component.took_damage.connect(_on_owner_took_damage)

func teardown() -> void:
	if is_instance_valid(_fx_manager):
		_fx_manager.cancel_effect_on_node(_visual_node)

	if is_instance_valid(_health_component):
		if _health_component.took_damage.is_connected(_on_owner_took_damage):
			_health_component.took_damage.disconnect(_on_owner_took_damage)

	_visual_node = null
	_owner = null
	_health_component = null
	_fx_manager = null

# --- Public API ---
func play_effect(effect: ShaderEffect, overrides: Dictionary = {}, opts: Dictionary = {}) -> Tween:
	if not is_instance_valid(_visual_node):
		push_warning("FXComponent cannot play effect: visual node is invalid.")
		return null
	return _fx_manager.apply_shader_effect(_visual_node, effect, overrides, opts)

# --- Signal Handlers ---
func _on_owner_took_damage(_damage_info: DamageInfo, _damage_result: DamageResult) -> void:
	if is_instance_valid(_hit_effect):
		play_effect(_hit_effect)
