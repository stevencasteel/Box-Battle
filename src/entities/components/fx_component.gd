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
var _services: IFXManager

# --- Godot Lifecycle Methods ---
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		teardown()

func setup(p_owner: Node, p_dependencies: Dictionary = {}) -> void:
	self._owner = p_owner
	var service_locator: ServiceLocator = p_dependencies.get("services")
	assert(is_instance_valid(service_locator), "FXComponent requires a ServiceLocator.")
	self._services = service_locator.fx_manager
	assert(is_instance_valid(_services), "FXComponent could not get IFXManager from ServiceLocator.")

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
	if is_instance_valid(_services):
		_services.cancel_effect_on_node(_visual_node)

	if is_instance_valid(_health_component):
		if _health_component.took_damage.is_connected(_on_owner_took_damage):
			_health_component.took_damage.disconnect(_on_owner_took_damage)

	_visual_node = null
	_owner = null
	_health_component = null
	_services = null

# --- Public API ---

func play_effect(effect: ShaderEffect, overrides: Dictionary = {}, opts: Dictionary = {}) -> Tween:
	if not is_instance_valid(_visual_node):
		push_warning("FXComponent cannot play effect: visual node is invalid.")
		return null
	return _services.apply_shader_effect(_visual_node, effect, overrides, opts)

# --- Signal Handlers ---

func _on_owner_took_damage(_damage_info: DamageInfo, _damage_result: DamageResult) -> void:
	if is_instance_valid(_hit_effect):
		play_effect(_hit_effect)
