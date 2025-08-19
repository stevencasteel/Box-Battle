# src/entities/components/fx_component.gd
@tool
## A dedicated component for managing all entity-specific visual effects.
class_name FXComponent
extends IComponent

@export var visual_node: CanvasItem

# --- Private Member Variables ---
var _owner: Node
var _original_material: Material
var _is_effect_active: bool = false
var _hit_flash_shader: Shader

# --- Godot Lifecycle Methods ---

func _ready() -> void:
	# Pre-compile the simple shader once to avoid doing it on every hit.
	_hit_flash_shader = Shader.new()
	_hit_flash_shader.code = "shader_type canvas_item; uniform vec4 tint_color : source_color; void fragment() { COLOR = tint_color; }"

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		teardown()

func setup(p_owner: Node, p_dependencies: Dictionary = {}) -> void:
	self._owner = p_owner
	var health_comp: HealthComponent = p_dependencies.get("health_component")
	
	if not is_instance_valid(visual_node):
		push_warning("FXComponent missing visual_node at setup time on '%s'." % get_parent().name)
	
	if is_instance_valid(health_comp):
		var cb = Callable(self, "_on_health_component_took_damage")
		if not health_comp.took_damage.is_connected(cb):
			health_comp.took_damage.connect(cb)

func teardown() -> void:
	var health_comp: HealthComponent = _owner.get("health_component") if is_instance_valid(_owner) else null
	if is_instance_valid(health_comp) and health_comp.took_damage.is_connected(_on_health_component_took_damage):
		health_comp.took_damage.disconnect(_on_health_component_took_damage)

	visual_node = null
	_owner = null

# --- Private Methods ---

func _on_effect_finished() -> void:
	if is_instance_valid(visual_node):
		visual_node.material = _original_material
	_is_effect_active = false

# --- Signal Handlers ---

func _on_health_component_took_damage(_damage_info: DamageInfo, _damage_result: DamageResult) -> void:
	# Prevent overlapping effects from causing issues.
	if _is_effect_active or not is_instance_valid(visual_node):
		return

	_is_effect_active = true
	_original_material = visual_node.material

	# Create and apply the simple shader material.
	var flash_material = ShaderMaterial.new()
	flash_material.shader = _hit_flash_shader
	flash_material.set_shader_parameter("tint_color", Color.RED)
	visual_node.material = flash_material
	
	# Use a simple, one-shot SceneTreeTimer to revert the effect.
	get_tree().create_timer(0.12).timeout.connect(_on_effect_finished)
