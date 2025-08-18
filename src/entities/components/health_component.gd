# src/entities/components/health_component.gd
@tool
## Manages all health, damage, and invincibility logic for an entity.
##
## This component is the single point of contact for applying damage. It handles
## hit flashes, knockback calculation, invincibility frames, and communicates
## health changes and death events via signals.
class_name HealthComponent
extends IComponent

# --- Signals ---
## Emitted whenever health changes.
signal health_changed(current_health: int, max_health: int)
## Emitted when health drops to or below zero.
signal died
## Emitted when health crosses a pre-defined percentage threshold.
signal health_threshold_reached(health_percentage: float)

# --- Node References ---
@onready var invincibility_timer: Timer = Timer.new()
@onready var hit_flash_timer: Timer = Timer.new()

# --- Member Variables ---
var entity_data: Resource
var owner_node: CharacterBody2D
var armor_component: ArmorComponent

var _max_health: int
var _invincibility_duration: float
var _knockback_speed: float
var _hazard_knockback_speed: float
var _invincibility_callable: Callable

# --- Godot Lifecycle Methods ---

func _ready() -> void:
	add_child(invincibility_timer)
	add_child(hit_flash_timer)
	invincibility_timer.one_shot = true
	hit_flash_timer.wait_time = 0.4

	_invincibility_callable = func(): entity_data.is_invincible = false
	invincibility_timer.timeout.connect(_invincibility_callable)
	hit_flash_timer.timeout.connect(_on_hit_flash_timer_timeout)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		teardown()

# --- Public Methods ---

## Initializes the component with entity-specific data and configuration.
func setup(p_owner: Node, p_dependencies: Dictionary = {}) -> void:
	self.owner_node = p_owner as CharacterBody2D
	self.entity_data = p_dependencies.get("data_resource")
	var cfg: CombatConfig = p_dependencies.get("config")

	self.armor_component = owner_node.get_node_or_null("ArmorComponent")

	if not entity_data or not cfg:
		push_error("HealthComponent.setup: Missing required dependencies ('data_resource', 'config').")
		return

	_max_health = entity_data.max_health
	if owner_node.is_in_group(Identifiers.Groups.PLAYER):
		_invincibility_duration = cfg.player_invincibility_duration
		_knockback_speed = cfg.player_knockback_speed
		_hazard_knockback_speed = cfg.player_hazard_knockback_speed
	else: # Assumes Enemy/Boss
		_invincibility_duration = cfg.boss_invincibility_duration
		_knockback_speed = 0
		_hazard_knockback_speed = 0

	entity_data.health = _max_health

	var sprite = _get_visual_sprite()
	if is_instance_valid(sprite) and not sprite.has_meta("original_color"):
		sprite.set_meta("original_color", sprite.color)

	health_changed.emit(entity_data.health, _max_health)

## Safely cleans up references and disconnects signals.
func teardown() -> void:
	if is_instance_valid(invincibility_timer) and invincibility_timer.timeout.is_connected(_invincibility_callable):
		invincibility_timer.timeout.disconnect(_invincibility_callable)
	if is_instance_valid(hit_flash_timer) and hit_flash_timer.timeout.is_connected(_on_hit_flash_timer_timeout):
		hit_flash_timer.timeout.disconnect(_on_hit_flash_timer_timeout)

	entity_data = null
	owner_node = null
	armor_component = null

## The primary public method for dealing damage to this entity.
func apply_damage(damage_info: DamageInfo) -> DamageResult:
	var result = DamageResult.new()
	var is_dash_invincible = entity_data.is_dash_invincible if "is_dash_invincible" in entity_data else false

	if (is_instance_valid(armor_component) and armor_component.is_armored) or \
		((entity_data.is_invincible or is_dash_invincible) and not damage_info.bypass_invincibility):
		return result

	var health_before_damage = entity_data.health
	entity_data.health -= damage_info.amount
	health_changed.emit(entity_data.health, _max_health)

	_trigger_hit_flash()

	entity_data.is_invincible = true
	invincibility_timer.start(_invincibility_duration)

	result.knockback_velocity = _calculate_knockback(damage_info.source_node)
	_check_for_threshold_crossing(health_before_damage, entity_data.health)

	if entity_data.health <= 0:
		died.emit()

	result.was_damaged = true
	return result

# --- Private Methods ---

func _check_for_threshold_crossing(health_before: int, health_after: int) -> void:
	if not owner_node.has_method("get_health_thresholds"): return

	var thresholds: Array[float] = owner_node.get_health_thresholds()
	var old_percent = float(health_before) / _max_health
	var new_percent = float(health_after) / _max_health

	for threshold in thresholds:
		if old_percent > threshold and new_percent <= threshold:
			health_threshold_reached.emit(threshold)

func _calculate_knockback(source: Node) -> Vector2:
	if _knockback_speed == 0 or not is_instance_valid(source): return Vector2.ZERO

	var knockback_dir = (owner_node.global_position - source.global_position).normalized()
	var speed = _knockback_speed
	if source.is_in_group(Identifiers.Groups.HAZARD):
		speed = _hazard_knockback_speed

	return (knockback_dir + Vector2.UP * 0.5).normalized() * speed

func _trigger_hit_flash() -> void:
	var sprite = _get_visual_sprite()
	if is_instance_valid(sprite):
		if not sprite.has_meta("original_color"):
			sprite.set_meta("original_color", sprite.color)

		sprite.color = Palette.COLOR_UI_ACCENT_PRIMARY
		hit_flash_timer.start()

func _get_visual_sprite() -> ColorRect:
	if is_instance_valid(owner_node):
		return owner_node.get_node_or_null("ColorRect")
	return null

# --- Signal Handlers ---

func _on_hit_flash_timer_timeout() -> void:
	var sprite = _get_visual_sprite()
	if is_instance_valid(sprite) and sprite.has_meta("original_color"):
		sprite.color = sprite.get_meta("original_color")