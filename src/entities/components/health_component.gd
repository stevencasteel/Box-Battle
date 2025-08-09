# src/entities/components/health_component.gd
#
# A component responsible for managing an entity's health, damage intake,
# invincibility, and death. Made generic to work with both Player and Boss.
class_name HealthComponent
extends Node

signal health_changed(current_health: int, max_health: int)
signal died

# --- Dependencies ---
var entity_data: Resource # Can be PlayerStateData or BossStateData
var owner_node: CharacterBody2D

# --- Node References ---
@onready var invincibility_timer: Timer = Timer.new()
@onready var hit_flash_timer: Timer = Timer.new()

# --- Config ---
var max_health: int
var invincibility_duration: float
var _knockback_config: Dictionary = {}

# --- Internal State ---
var original_color: Color

func _ready():
	add_child(invincibility_timer)
	add_child(hit_flash_timer)
	
	invincibility_timer.one_shot = true
	hit_flash_timer.one_shot = true
	hit_flash_timer.wait_time = 0.4
	
	invincibility_timer.timeout.connect(func(): entity_data.is_invincible = false)
	hit_flash_timer.timeout.connect(_on_hit_flash_timer_timeout)

func _exit_tree():
	entity_data = null
	owner_node = null
	EventBus.off_owner(self)

func setup(p_entity_data: Resource, p_owner_node: CharacterBody2D, config_paths: Dictionary):
	self.entity_data = p_entity_data
	self.owner_node = p_owner_node
	
	max_health = Config.get_value(config_paths.max_health, 10)
	invincibility_duration = Config.get_value(config_paths.get("invincibility", "player.health.invincibility_duration"), 1.0)
	
	if config_paths.has("knockback"):
		_knockback_config = config_paths.knockback
	
	entity_data.health = max_health
	if is_instance_valid(get_visual_sprite()):
		original_color = get_visual_sprite().color
	
	health_changed.emit(entity_data.health, max_health)

func take_damage(damage_amount: int, damage_source: Node = null) -> Dictionary:
	var is_dash_invincible = entity_data.get("is_dash_invincible") if "is_dash_invincible" in entity_data else false
	if entity_data.is_invincible or is_dash_invincible:
		return {"was_damaged": false}

	entity_data.health -= damage_amount
	health_changed.emit(entity_data.health, max_health)
	
	_trigger_hit_flash()
	entity_data.is_invincible = true
	invincibility_timer.start(invincibility_duration)
	
	var knockback_info = _calculate_knockback(damage_source)
	
	if entity_data.health <= 0:
		died.emit()
		
	return {"was_damaged": true, "knockback_velocity": knockback_info}

func _calculate_knockback(damage_source: Node) -> Vector2:
	if _knockback_config.is_empty() or not damage_source:
		return Vector2.ZERO
		
	var knockback_dir = (owner_node.global_position - damage_source.global_position).normalized()
	
	var knockback_speed = Config.get_value(_knockback_config.speed, 400.0)
	if damage_source.is_in_group("hazard"):
		knockback_speed = Config.get_value(_knockback_config.hazard_speed, knockback_speed)
		
	return (knockback_dir + Vector2.UP * 0.5).normalized() * knockback_speed

func _trigger_hit_flash():
	if is_instance_valid(get_visual_sprite()):
		get_visual_sprite().color = Palette.get_color(16)
		hit_flash_timer.start()

func get_visual_sprite() -> ColorRect:
	if is_instance_valid(owner_node):
		return owner_node.get_node_or_null("ColorRect")
	return null

func _on_hit_flash_timer_timeout():
	if is_instance_valid(get_visual_sprite()):
		get_visual_sprite().color = original_color
