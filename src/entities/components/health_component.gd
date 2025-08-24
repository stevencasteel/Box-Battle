# src/entities/components/health_component.gd
@tool
## Manages all health, damage, and invincibility logic for an entity.
## Implements the IDamageable interface.
class_name HealthComponent
extends IDamageable

# --- Signals ---
signal health_changed(current_health: int, max_health: int)
signal died
signal health_threshold_reached(health_percentage: float)
signal took_damage(damage_info: DamageInfo, damage_result: DamageResult)

# --- Member Variables ---
var entity_data: Resource
var owner_node: CharacterBody2D

var _max_health: int
var _invincibility_duration: float
var _knockback_speed: float
var _hazard_knockback_speed: float
var _invincibility_tokens: Dictionary = {}
var _next_token_id: int = 1
var _services: ServiceLocator
var _hit_spark_effect: VFXEffect

# --- Godot Lifecycle Methods ---


func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		teardown()


# --- Public Methods (IComponent Contract) ---


func setup(p_owner: Node, p_dependencies: Dictionary = {}) -> void:
	self.owner_node = p_owner as CharacterBody2D
	self.entity_data = p_dependencies.get("data_resource")
	var cfg: CombatConfig = p_dependencies.get("config")
	self._services = p_dependencies.get("services")
	self._hit_spark_effect = p_dependencies.get("hit_spark_effect")

	if not entity_data or not cfg or not _services:
		push_error("HealthComponent.setup: Missing required dependencies.")
		return

	_max_health = entity_data.max_health
	if owner_node.is_in_group(Identifiers.Groups.PLAYER):
		_invincibility_duration = cfg.player_invincibility_duration
		_knockback_speed = cfg.player_knockback_speed
		_hazard_knockback_speed = cfg.player_hazard_knockback_speed
	else:
		_invincibility_duration = cfg.boss_invincibility_duration
		_knockback_speed = 0
		_hazard_knockback_speed = 0

	entity_data.health = _max_health
	health_changed.emit(entity_data.health, _max_health)


func teardown() -> void:
	entity_data = null
	owner_node = null
	_services = null
	_hit_spark_effect = null


# --- Public Methods (IDamageable Contract) ---


func apply_damage(damage_info: DamageInfo) -> DamageResult:
	var result := DamageResult.new()

	if not is_instance_valid(damage_info):
		push_warning("HealthComponent received an invalid DamageInfo object.")
		return result

	if is_invincible() and not damage_info.bypass_invincibility:
		return result

	var health_before_damage: int = entity_data.health
	entity_data.health -= damage_info.amount
	health_changed.emit(entity_data.health, _max_health)

	var post_hit_token: int = grant_invincibility(self)
	get_tree().create_timer(_invincibility_duration).timeout.connect(
		release_invincibility.bind(post_hit_token)
	)

	result.knockback_velocity = _calculate_knockback(damage_info.source_node)
	_check_for_threshold_crossing(health_before_damage, entity_data.health)

	result.was_damaged = true
	took_damage.emit(damage_info, result)

	if result.was_damaged and is_instance_valid(_services) and is_instance_valid(_hit_spark_effect):
		_services.fx_manager.play_vfx(
			_hit_spark_effect, damage_info.impact_position, damage_info.impact_normal
		)

	if entity_data.health <= 0:
		died.emit()

	return result


# --- Public Methods (HealthComponent Specific) ---


func is_invincible() -> bool:
	return not _invincibility_tokens.is_empty()


func grant_invincibility(requester: Object) -> int:
	var token_id := _next_token_id
	_next_token_id += 1
	_invincibility_tokens[token_id] = requester.get_instance_id()
	return token_id


func release_invincibility(token: int) -> void:
	if _invincibility_tokens.has(token):
		_invincibility_tokens.erase(token)


# --- Private Methods ---
func _check_for_threshold_crossing(health_before: int, health_after: int) -> void:
	if not owner_node.has_method("get_health_thresholds"):
		return
	var thresholds: Array[float] = owner_node.get_health_thresholds()
	var old_percent: float = float(health_before) / _max_health
	var new_percent: float = float(health_after) / _max_health
	for threshold in thresholds:
		if old_percent > threshold and new_percent <= threshold:
			health_threshold_reached.emit(threshold)


func _calculate_knockback(source: Node) -> Vector2:
	if _knockback_speed == 0 or not is_instance_valid(source):
		return Vector2.ZERO
	var knockback_dir: Vector2 = (owner_node.global_position - source.global_position).normalized()
	var speed: float = _knockback_speed
	if source.is_in_group(Identifiers.Groups.HAZARD):
		speed = _hazard_knockback_speed
	return (knockback_dir + Vector2.UP * 0.5).normalized() * speed