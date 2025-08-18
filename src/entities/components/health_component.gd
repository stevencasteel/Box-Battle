# src/entities/components/health_component.gd
@tool
## Manages all health, damage, and invincibility logic for an entity.
##
## This component is the single source of truth for damage and invincibility.
## It uses a token-based system to manage multiple, overlapping sources of
## invulnerability (e.g., post-hit i-frames, ability-based armor).
class_name HealthComponent
extends IComponent

# --- Signals ---
signal health_changed(current_health: int, max_health: int)
signal died
signal health_threshold_reached(health_percentage: float)
## Emitted after damage has been successfully applied.
signal took_damage(damage_info: DamageInfo, damage_result: DamageResult)

# --- Node References ---
@onready var hit_flash_timer: Timer = Timer.new()

# --- Member Variables ---
var entity_data: Resource
var owner_node: CharacterBody2D

var _max_health: int
var _invincibility_duration: float
var _knockback_speed: float
var _hazard_knockback_speed: float
var _invincibility_tokens: Dictionary = {}
var _next_token_id: int = 1

# --- Godot Lifecycle Methods ---

func _ready() -> void:
	add_child(hit_flash_timer)
	hit_flash_timer.wait_time = 0.4
	hit_flash_timer.timeout.connect(_on_hit_flash_timer_timeout)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		teardown()

# --- Public Methods ---

## Returns true if the entity has any active invincibility tokens.
func is_invincible() -> bool:
	return not _invincibility_tokens.is_empty()

## Requests a temporary grant of invincibility. Returns a token ID.
## The requester is responsible for calling release_invincibility() with this token.
func grant_invincibility(requester: Object) -> int:
	var token_id = _next_token_id
	_next_token_id += 1
	_invincibility_tokens[token_id] = requester.get_instance_id()
	return token_id

## Releases an invincibility token, removing one source of invulnerability.
func release_invincibility(token: int) -> void:
	if _invincibility_tokens.has(token):
		_invincibility_tokens.erase(token)

func setup(p_owner: Node, p_dependencies: Dictionary = {}) -> void:
	self.owner_node = p_owner as CharacterBody2D
	self.entity_data = p_dependencies.get("data_resource")
	var cfg: CombatConfig = p_dependencies.get("config")

	if not entity_data or not cfg:
		push_error("HealthComponent.setup: Missing required dependencies.")
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

func teardown() -> void:
	if is_instance_valid(hit_flash_timer) and hit_flash_timer.timeout.is_connected(_on_hit_flash_timer_timeout):
		hit_flash_timer.timeout.disconnect(_on_hit_flash_timer_timeout)
	entity_data = null
	owner_node = null

func apply_damage(damage_info: DamageInfo) -> DamageResult:
	var result = DamageResult.new()

	if is_invincible() and not damage_info.bypass_invincibility:
		return result

	var health_before_damage = entity_data.health
	entity_data.health -= damage_info.amount
	health_changed.emit(entity_data.health, _max_health)

	_trigger_hit_flash()

	var post_hit_token = grant_invincibility(self)
	get_tree().create_timer(_invincibility_duration).timeout.connect(release_invincibility.bind(post_hit_token))

	result.knockback_velocity = _calculate_knockback(damage_info.source_node)
	_check_for_threshold_crossing(health_before_damage, entity_data.health)

	result.was_damaged = true
	# THE FIX: Pass the full DamageInfo object with the event payload.
	took_damage.emit(damage_info, result)

	if entity_data.health <= 0:
		died.emit()

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
func _on_hit_flash_timer_timeout() -> void:
	var sprite = _get_visual_sprite()
	if is_instance_valid(sprite) and sprite.has_meta("original_color"):
		sprite.color = sprite.get_meta("original_color")