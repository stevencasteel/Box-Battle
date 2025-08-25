# src/entities/components/combat_component.gd
@tool
## Centralizes all player combat logic, such as firing projectiles and pogo attacks.
class_name CombatComponent
extends IComponent

# --- Signals ---
signal damage_dealt
signal pogo_bounce_requested

# --- Member Variables ---
var owner_node: CharacterBody2D
var p_data: PlayerStateData
var _object_pool: IObjectPool
var _fx_manager: IFXManager
var _combat_utils: CombatUtils
var _services: ServiceLocator

# --- Public Methods ---
func setup(p_owner: Node, p_dependencies: Dictionary = {}) -> void:
	self.owner_node = p_owner as CharacterBody2D
	self.p_data = p_dependencies.get("data_resource")
	
	self._object_pool = p_dependencies.get("object_pool")
	self._fx_manager = p_dependencies.get("fx_manager")
	self._combat_utils = p_dependencies.get("combat_utils")
	self._services = p_dependencies.get("services")
	
	assert(is_instance_valid(_object_pool), "CombatComponent requires an IObjectPool.")
	assert(is_instance_valid(_fx_manager), "CombatComponent requires an IFXManager.")
	assert(is_instance_valid(_combat_utils), "CombatComponent requires a CombatUtils.")
	assert(is_instance_valid(_services), "CombatComponent requires a ServiceLocator.")


func teardown() -> void:
	owner_node = null
	p_data = null
	_object_pool = null
	_fx_manager = null
	_combat_utils = null
	_services = null


## Fires a player projectile from the object pool.
func fire_shot() -> void:
	p_data.attack_cooldown_timer = p_data.config.player_attack_cooldown

	var shot = _object_pool.get_instance(Identifiers.Pools.PLAYER_SHOTS)
	if not shot:
		return

	var shot_dir = Vector2(p_data.facing_direction, 0)
	var ic: InputComponent = owner_node.get_component(InputComponent)
	if is_instance_valid(ic):
		if ic.buffer.get("up"):
			shot_dir = Vector2.UP
		elif ic.buffer.get("down"):
			shot_dir = Vector2.DOWN

	shot.direction = shot_dir
	shot.global_position = owner_node.global_position + (shot_dir * 60)
	shot.activate(_services)


## Handles a melee hitbox collision.
func trigger_melee_attack(target_body: Node) -> void:
	var target_id = target_body.get_instance_id()
	if p_data.hit_targets_this_swing.has(target_id):
		return

	p_data.hit_targets_this_swing[target_id] = true
	var damageable = _combat_utils.find_damageable(target_body)
	if is_instance_valid(damageable):
		var damage_info = DamageInfo.new()
		damage_info.source_node = owner_node
		var distance = owner_node.global_position.distance_to(target_body.global_position)
		var is_close_range = distance <= p_data.config.player_close_range_threshold
		damage_info.amount = 5 if is_close_range else 1
		damage_info.impact_position = target_body.global_position
		damage_info.impact_normal = (target_body.global_position - owner_node.global_position).normalized()

		var damage_result = damageable.apply_damage(damage_info)
		if damage_result.was_damaged:
			damage_dealt.emit()
			if is_close_range:
				_fx_manager.request_hit_stop(
					p_data.config.player_melee_close_range_hit_stop_duration
				)


## Attempts to perform a pogo action on a target.
func trigger_pogo(pogo_target: Node) -> bool:
	if not p_data.is_pogo_attack:
		return false
	if not is_instance_valid(pogo_target):
		return false

	var should_bounce = false

	if pogo_target.is_in_group(Identifiers.Groups.ENEMY_PROJECTILE):
		should_bounce = true
		_object_pool.return_instance.call_deferred(pogo_target)

	var damageable = _combat_utils.find_damageable(pogo_target)
	if is_instance_valid(damageable):
		should_bounce = true
		var damage_info = DamageInfo.new()
		damage_info.amount = 1
		damage_info.source_node = owner_node
		damage_info.bypass_invincibility = true
		damage_info.impact_position = pogo_target.global_position
		damage_info.impact_normal = Vector2.UP
		var damage_result = damageable.apply_damage(damage_info)
		if damage_result.was_damaged:
			damage_dealt.emit()

	if pogo_target is StaticBody2D and pogo_target.is_in_group(Identifiers.Groups.WORLD):
		should_bounce = true

	if should_bounce:
		pogo_bounce_requested.emit()
		return true

	return false
