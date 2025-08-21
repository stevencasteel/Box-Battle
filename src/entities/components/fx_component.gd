# src/entities/components/fx_component.gd
@tool
## A dedicated component for managing all entity-specific visual effects.
##
## CONTRACT: This component requires the following dependencies to be passed
## into its setup() method:
##  - "visual_node": A CanvasItem to which the shader will be applied.
##  - "health_component": A HealthComponent to connect the `took_damage` signal.
class_name FXComponent
extends IComponent

# --- Constants ---
const HIT_FLASH_SHADER = preload("res://shaders/entity/red_hit_flash_test.gdshader")

# --- Member Variables ---
var _owner: Node
var _visual_node: CanvasItem
var _original_material: Material
var _hit_flash_material: ShaderMaterial
var _active_tween: Tween

# A proxy property for the tween to animate.
var _intensity: float = 0.0:
	set(value):
		_intensity = value
		if is_instance_valid(_hit_flash_material):
			_hit_flash_material.set_shader_parameter("intensity", _intensity)

# --- Godot Lifecycle Methods ---
func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		teardown()

func setup(p_owner: Node, p_dependencies: Dictionary = {}) -> void:
	self._owner = p_owner
	
	# --- Dependency Validation ---
	assert(p_dependencies.has("visual_node"), "FXComponent requires a 'visual_node' dependency.")
	assert(p_dependencies.has("health_component"), "FXComponent requires a 'health_component' dependency.")
	self._visual_node = p_dependencies.get("visual_node")
	var health_comp: HealthComponent = p_dependencies.get("health_component")
	assert(is_instance_valid(_visual_node) and _visual_node is CanvasItem, "'visual_node' must be a valid CanvasItem.")
	assert(is_instance_valid(health_comp) and health_comp is HealthComponent, "'health_component' must be a valid HealthComponent.")

	# --- Initialization ---
	_hit_flash_material = ShaderMaterial.new()
	_hit_flash_material.shader = HIT_FLASH_SHADER

	if is_instance_valid(health_comp):
		health_comp.took_damage.connect(_on_health_component_took_damage)

func teardown() -> void:
	if is_instance_valid(_active_tween):
		_active_tween.kill()

	var health_comp: HealthComponent = _owner.get("health_component") if is_instance_valid(_owner) else null
	if is_instance_valid(health_comp) and health_comp.took_damage.is_connected(_on_health_component_took_damage):
		health_comp.took_damage.disconnect(_on_health_component_took_damage)

	_visual_node = null
	_owner = null

# --- Private Methods ---
func _play_hit_flash() -> void:
	if not is_instance_valid(_visual_node) or not is_instance_valid(_hit_flash_material):
		return
		
	if is_instance_valid(_active_tween):
		_active_tween.kill()

	_original_material = _visual_node.material
	
	_visual_node.material = _hit_flash_material
	
	self._intensity = 1.0
	
	_active_tween = create_tween()
	_active_tween.tween_property(self, "_intensity", 0.0, 0.12)
	_active_tween.finished.connect(_on_flash_finished)

func _on_flash_finished() -> void:
	if is_instance_valid(_visual_node):
		_visual_node.material = _original_material
	_active_tween = null

# --- Signal Handlers ---

func _on_health_component_took_damage(damage_info: DamageInfo, _damage_result: DamageResult) -> void:
	_play_hit_flash()
	
	# The Player and Boss now pass their specific effect resources via their main scripts.
	var owner_player = _owner as Player
	if is_instance_valid(owner_player):
		if is_instance_valid(owner_player.damage_shake_effect):
			FXManager.request_screen_shake(owner_player.damage_shake_effect)
		FXManager.request_hit_stop(owner_player.entity_data.config.player_damage_taken_hit_stop_duration)
		if is_instance_valid(owner_player.hit_spark_effect):
			FXManager.play_vfx(owner_player.hit_spark_effect, damage_info.impact_position, damage_info.impact_normal)
			
	var owner_boss = _owner as BaseBoss
	if is_instance_valid(owner_boss):
		if is_instance_valid(owner_boss.hit_spark_effect):
			FXManager.play_vfx(owner_boss.hit_spark_effect, damage_info.impact_position, damage_info.impact_normal)

	var owner_turret = _owner as Turret
	if is_instance_valid(owner_turret):
		if is_instance_valid(owner_turret.hit_spark_effect):
			FXManager.play_vfx(owner_turret.hit_spark_effect, damage_info.impact_position, damage_info.impact_normal)