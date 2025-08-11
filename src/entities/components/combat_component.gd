# src/entities/components/combat_component.gd
#
# A component that handles the execution of the player's combat abilities.
# It is now decoupled and emits signals for its owner to react to.
class_name CombatComponent
extends ComponentInterface

signal damage_dealt
signal pogo_bounce_requested

var owner_node: CharacterBody2D
var p_data: PlayerStateData

func setup(p_owner: Node, _config: Resource = null, _services = null) -> void:
	self.owner_node = p_owner as CharacterBody2D
	self.p_data = owner_node.p_data

func teardown() -> void:
	owner_node = null
	p_data = null

func fire_shot():
	p_data.attack_cooldown_timer = CombatDB.config.player_attack_cooldown
	
	var shot = ObjectPool.get_instance(&"player_shots")
	if not shot: return
	
	var shot_dir = Vector2(p_data.facing_direction, 0)
	if Input.is_action_pressed("ui_up"): shot_dir = Vector2.UP
	elif Input.is_action_pressed("ui_down"): shot_dir = Vector2.DOWN
	
	shot.direction = shot_dir
	shot.global_position = owner_node.global_position + (shot_dir * 60)
	shot.activate()

func trigger_pogo(pogo_target) -> bool:
	if not is_instance_valid(pogo_target):
		return false

	var should_bounce = false
	
	# Can bounce on projectiles.
	if p_data.is_pogo_attack and pogo_target.is_in_group("enemy_projectile"):
		should_bounce = true
		ObjectPool.return_instance(pogo_target)
	
	# Can bounce on enemies and deal damage.
	var health_comp = CombatUtils.find_health_component(pogo_target)
	if health_comp:
		should_bounce = true
		var damage_result = health_comp.take_damage(1, owner_node, true)
		if damage_result["was_damaged"]:
			damage_dealt.emit()

	# Can bounce on the ground or any solid world tile.
	if pogo_target is StaticBody2D and pogo_target.is_in_group("world"):
		should_bounce = true

	if should_bounce:
		pogo_bounce_requested.emit()
		return true

	return false