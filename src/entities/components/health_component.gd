# src/entities/components/health_component.gd
#
# A component responsible for managing an entity's health, damage intake,
# invincibility, and death.
class_name HealthComponent
extends Node

signal health_changed(current_health: int, max_health: int)
signal died

# --- Dependencies ---
var p_data: PlayerStateData
var owner_node: CharacterBody2D

# --- Node References ---
@onready var invincibility_timer: Timer = Timer.new()
@onready var hit_flash_timer: Timer = Timer.new()

# --- Config ---
var max_health: int
var invincibility_duration: float

# --- Internal State ---
var original_color: Color

func _ready():
	add_child(invincibility_timer)
	add_child(hit_flash_timer)
	invincibility_timer.one_shot = true
	hit_flash_timer.one_shot = true
	hit_flash_timer.wait_time = 0.4
	
	invincibility_timer.timeout.connect(func(): p_data.is_invincible = false)
	hit_flash_timer.timeout.connect(func(): 
		if is_instance_valid(get_visual_sprite()):
			get_visual_sprite().color = original_color
	)

# NEW: This is the critical fix. When the component is about to be freed,
# it explicitly nullifies its references to external objects, breaking any
# potential reference cycles and allowing the p_data resource to be freed.
func _exit_tree():
	p_data = null
	owner_node = null
	EventBus.off_owner(self)

func setup(player_data: PlayerStateData, p_owner_node: CharacterBody2D):
	self.p_data = player_data
	self.owner_node = p_owner_node
	
	max_health = Config.get_value("player.health.max_health", 5)
	invincibility_duration = Config.get_value("player.health.invincibility_duration", 1.5)
	
	p_data.health = max_health
	original_color = get_visual_sprite().color
	
	health_changed.emit(p_data.health, max_health)

func take_damage(damage_amount: int, damage_source: Node = null) -> Dictionary:
	if p_data.is_invincible or p_data.is_dash_invincible:
		return {"was_damaged": false}

	p_data.health -= damage_amount
	health_changed.emit(p_data.health, max_health)
	
	_trigger_hit_flash()
	p_data.is_invincible = true
	invincibility_timer.start(invincibility_duration)
	
	var knockback_info = _calculate_knockback(damage_source)
	
	if p_data.health <= 0:
		died.emit()
		
	return {"was_damaged": true, "knockback_velocity": knockback_info}

func _calculate_knockback(damage_source: Node) -> Vector2:
	if not damage_source:
		return Vector2.ZERO
		
	var knockback_dir = (owner_node.global_position - damage_source.global_position).normalized()
	var knockback_str = Config.get_value("player.combat.knockback_speed")
	if damage_source.is_in_group("hazard"):
		knockback_str = Config.get_value("player.combat.hazard_knockback_speed")
		
	return (knockback_dir + Vector2.UP * 0.5).normalized() * knockback_str

func _trigger_hit_flash():
	if is_instance_valid(get_visual_sprite()):
		get_visual_sprite().color = Palette.get_color(16)
		hit_flash_timer.start()

func get_visual_sprite() -> ColorRect:
	if is_instance_valid(owner_node):
		return owner_node.get_node_or_null("ColorRect")
	return null
