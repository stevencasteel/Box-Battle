# src/entities/components/health_component.gd
# MODIFIED: The call to FXManager for hit-stop has been commented out.
class_name HealthComponent
extends ComponentInterface

signal health_changed(current_health: int, max_health: int)
signal died
signal health_threshold_reached(health_percentage: float)

var entity_data: Resource
var owner_node: CharacterBody2D
var armor_component: ArmorComponent

@onready var invincibility_timer: Timer = Timer.new()
@onready var hit_flash_timer: Timer = Timer.new()

var max_health: int
var invincibility_duration: float
var knockback_speed: float
var hazard_knockback_speed: float

func _ready():
	add_child(invincibility_timer)
	add_child(hit_flash_timer)
	invincibility_timer.one_shot = true
	hit_flash_timer.wait_time = 0.4
	
	invincibility_timer.timeout.connect(func(): entity_data.is_invincible = false)
	hit_flash_timer.timeout.connect(_on_hit_flash_timer_timeout)

func setup(p_owner: Node, p_dependencies: Dictionary = {}) -> void:
	self.owner_node = p_owner as CharacterBody2D
	self.entity_data = p_dependencies.get("data_resource")
	var cfg: CombatConfig = p_dependencies.get("config")
	
	self.armor_component = owner_node.get_node_or_null("ArmorComponent")
	
	if not entity_data or not cfg:
		push_error("HealthComponent.setup: Missing required dependencies ('data_resource', 'config').")
		return

	max_health = entity_data.max_health
	
	if owner_node.is_in_group(Identifiers.Groups.PLAYER):
		invincibility_duration = cfg.player_invincibility_duration
		knockback_speed = cfg.player_knockback_speed
		hazard_knockback_speed = cfg.player_hazard_knockback_speed
	else:
		invincibility_duration = cfg.boss_invincibility_duration
		knockback_speed = 0
		hazard_knockback_speed = 0
	
	entity_data.health = max_health
	
	var sprite = get_visual_sprite()
	if is_instance_valid(sprite) and not sprite.has_meta("original_color"):
		sprite.set_meta("original_color", sprite.color)
	
	health_changed.emit(entity_data.health, max_health)

func teardown() -> void:
	entity_data = null
	owner_node = null
	armor_component = null

func apply_damage(damage_info: DamageInfo) -> DamageResult:
	var result = DamageResult.new()
	
	if is_instance_valid(armor_component) and armor_component.is_armored:
		return result

	var is_dash_invincible = entity_data.get("is_dash_invincible") if "is_dash_invincible" in entity_data else false
	
	if (entity_data.is_invincible or is_dash_invincible) and not damage_info.bypass_invincibility:
		return result

	var health_before_damage = entity_data.health
	entity_data.health -= damage_info.amount
	health_changed.emit(entity_data.health, max_health)
	
	_trigger_hit_flash()
	
	entity_data.is_invincible = true
	invincibility_timer.start(invincibility_duration)
	
	result.knockback_velocity = _calculate_knockback(damage_info.source_node)
	
	_check_for_threshold_crossing(health_before_damage, entity_data.health)
	
	if entity_data.health <= 0:
		died.emit()
	
	result.was_damaged = true
	
	if result.was_damaged and owner_node.is_in_group(Identifiers.Groups.PLAYER):
		# FXManager.request_hit_stop(0.5)
		pass
	
	return result

func _check_for_threshold_crossing(health_before: int, health_after: int):
	if not owner_node.has_method("get_health_thresholds"): return
	var thresholds: Array[float] = owner_node.get_health_thresholds()
	var old_percent = float(health_before) / max_health
	var new_percent = float(health_after) / max_health
	
	for threshold in thresholds:
		if old_percent > threshold and new_percent <= threshold:
			health_threshold_reached.emit(threshold)

func _calculate_knockback(source: Node) -> Vector2:
	if knockback_speed == 0 or not is_instance_valid(source): return Vector2.ZERO
	var knockback_dir = (owner_node.global_position - source.global_position).normalized()
	var speed = knockback_speed
	if source.is_in_group(Identifiers.Groups.HAZARD):
		speed = hazard_knockback_speed
	return (knockback_dir + Vector2.UP * 0.5).normalized() * speed

func _trigger_hit_flash():
	var sprite = get_visual_sprite()
	if is_instance_valid(sprite):
		if not sprite.has_meta("original_color"):
			sprite.set_meta("original_color", sprite.color)
			
		sprite.color = Palette.COLOR_UI_ACCENT_PRIMARY
		hit_flash_timer.start()

func get_visual_sprite() -> ColorRect:
	if is_instance_valid(owner_node):
		return owner_node.get_node_or_null("ColorRect")
	return null

func _on_hit_flash_timer_timeout():
	var sprite = get_visual_sprite()
	if is_instance_valid(sprite):
		if sprite.has_meta("original_color"):
			sprite.color = sprite.get_meta("original_color")