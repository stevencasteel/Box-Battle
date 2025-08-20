# src/entities/components/fx_component.gd
@tool
## A dedicated component for managing all entity-specific visual effects.
## It acts as a decoupled bridge to the global FXManager.
class_name FXComponent
extends IComponent

# --- Member Variables ---
var _owner: Node
var _visual_node: CanvasItem
var _hit_flash_effect: ShaderEffect

# --- Godot Lifecycle Methods ---
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		teardown()

func setup(p_owner: Node, p_dependencies: Dictionary = {}) -> void:
	self._owner = p_owner
	self._visual_node = p_dependencies.get("visual_node")
	self._hit_flash_effect = p_dependencies.get("hit_flash_effect")
	var health_comp: HealthComponent = p_dependencies.get("health_component")

	if not is_instance_valid(_visual_node):
		push_warning("FXComponent on '%s' is missing its visual_node dependency." % get_parent().name)

	if is_instance_valid(health_comp):
		var cb = Callable(self, "_on_health_component_took_damage")
		if not health_comp.took_damage.is_connected(cb):
			health_comp.took_damage.connect(cb)

func teardown() -> void:
	var health_comp: HealthComponent = _owner.get("health_component") if is_instance_valid(_owner) else null
	if is_instance_valid(health_comp) and health_comp.took_damage.is_connected(_on_health_component_took_damage):
		health_comp.took_damage.disconnect(_on_health_component_took_damage)

	_visual_node = null
	_owner = null

# --- Signal Handlers ---

func _on_health_component_took_damage(_damage_info: DamageInfo, _damage_result: DamageResult) -> void:
	if is_instance_valid(_hit_flash_effect):
		FXManager.play_shader(_hit_flash_effect, _visual_node)
