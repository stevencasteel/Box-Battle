# src/entities/components/health_component.gd
#
# A component responsible for managing an entity's health, damage intake,
# invincibility, and death. It now implements the ComponentInterface standard.
class_name HealthComponent
extends ComponentInterface

signal health_changed(current_health: int, max_health: int)
signal died

var entity_data: Resource
var owner_node: CharacterBody2D

@onready var invincibility_timer: Timer = Timer.new()
@onready var hit_flash_timer: Timer = Timer.new()

var max_health: int
var invincibility_duration: float
var knockback_speed: float
var hazard_knockback_speed: float
var original_color: Color

func _ready():
	add_child(invincibility_timer)
	add_child(hit_flash_timer)
	invincibility_timer.one_shot = true
	hit_flash_timer.one_shot = true
	hit_flash_timer.wait_time = 0.4
	invincibility_timer.timeout.connect(func(): entity_data.is_invincible = false)
	hit_flash_timer.timeout.connect(_on_hit_flash_timer_timeout)

func setup(p_owner: Node, config: Resource = null, _services = null) -> void:
	self.owner_node = p_owner as CharacterBody2D
	
	var cfg: CombatConfig = config as CombatConfig
	if not cfg:
		push_error("HealthComponent.setup: passed config is not a CombatConfig resource.")
		return

	if owner_node.is_in_group("player"):
		self.entity_data = owner_node.p_data
		max_health = cfg.player_max_health
		invincibility_duration = cfg.player_invincibility_duration
		knockback_speed = cfg.player_knockback_speed
		hazard_knockback_speed = cfg.player_hazard_knockback_speed
	else:
		self.entity_data = owner_node.b_data
		max_health = cfg.boss_health
		invincibility_duration = cfg.boss_invincibility_duration
		knockback_speed = 0
		hazard_knockback_speed = 0
	
	entity_data.health = max_health
	if is_instance_valid(get_visual_sprite()):
		original_color = get_visual_sprite().color
	
	health_changed.emit(entity_data.health, max_health)

func teardown() -> void:
	entity_data = null
	owner_node = null

# MODIFIED: Added p_bypass_invincibility parameter
func take_damage(damage_amount: int, damage_source: Node = null, p_bypass_invincibility: bool = false) -> Dictionary:
	var is_dash_invincible = entity_data.get("is_dash_invincible") if "is_dash_invincible" in entity_data else false
	
	# MODIFIED: Check the bypass flag
	if (entity_data.is_invincible or is_dash_invincible) and not p_bypass_invincibility:
		return {"was_damaged": false}

	entity_data.health -= damage_amount
	health_changed.emit(entity_data.health, entity_data.max_health)
	
	_trigger_hit_flash()
	entity_data.is_invincible = true
	invincibility_timer.start(invincibility_duration)
	
	var knockback_info = _calculate_knockback(damage_source)
	
	if entity_data.health <= 0:
		died.emit()
		
	return {"was_damaged": true, "knockback_velocity": knockback_info}

func _calculate_knockback(damage_source: Node) -> Vector2:
	if knockback_speed == 0 or not damage_source:
		return Vector2.ZERO
		
	var knockback_dir = (owner_node.global_position - damage_source.global_position).normalized()
	
	var speed = knockback_speed
	if damage_source.is_in_group("hazard"):
		speed = hazard_knockback_speed
		
	return (knockback_dir + Vector2.UP * 0.5).normalized() * speed

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
