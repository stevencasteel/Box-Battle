# src/entities/components/combat_component.gd
# CORRECTED: Uses Identifiers constants for group checks.
class_name CombatComponent
extends ComponentInterface

const CombatUtilsScript = preload(AssetPaths.SCRIPT_COMBAT_UTILS)

signal damage_dealt
signal pogo_bounce_requested

var owner_node: CharacterBody2D
var p_data: PlayerStateData

func setup(p_owner: Node, p_dependencies: Dictionary = {}) -> void:
	self.owner_node = p_owner as CharacterBody2D
	self.p_data = p_dependencies.get("data_resource")
	
	if not p_data:
		push_error("CombatComponent.setup: Missing required dependency ('data_resource').")
		return

func teardown() -> void:
	owner_node = null
	p_data = null

func fire_shot():
	p_data.attack_cooldown_timer = p_data.config.player_attack_cooldown
	
	var shot = ObjectPool.get_instance(Identifiers.Pools.PLAYER_SHOTS)
	if not shot: return
	
	var shot_dir = Vector2(p_data.facing_direction, 0)
	if Input.is_action_pressed("ui_up"): shot_dir = Vector2.UP
	elif Input.is_action_pressed("ui_down"): shot_dir = Vector2.DOWN
	
	shot.direction = shot_dir
	shot.global_position = owner_node.global_position + (shot_dir * 60)
	shot.activate()

func trigger_pogo(pogo_target: Node) -> bool:
	if not is_instance_valid(pogo_target): return false

	var should_bounce = false
	
	if p_data.is_pogo_attack and pogo_target.is_in_group(Identifiers.Groups.ENEMY_PROJECTILE):
		should_bounce = true
		ObjectPool.return_instance(pogo_target)
	
	var damageable = CombatUtilsScript.find_damageable(pogo_target)
	if is_instance_valid(damageable):
		should_bounce = true
		var damage_info = DamageInfo.new()
		damage_info.amount = 1
		damage_info.source_node = owner_node
		damage_info.bypass_invincibility = true
		var damage_result = damageable.apply_damage(damage_info)
		if damage_result.was_damaged:
			damage_dealt.emit()

	if pogo_target is StaticBody2D and pogo_target.is_in_group(Identifiers.Groups.WORLD):
		should_bounce = true

	if should_bounce:
		pogo_bounce_requested.emit()
		return true

	return false
