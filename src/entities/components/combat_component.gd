# src/entities/components/combat_component.gd
#
# A component that handles the execution of the player's combat abilities.
class_name CombatComponent
extends ComponentInterface

signal damage_dealt

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

func trigger_pogo(pogo_target):
	if pogo_target and pogo_target.is_in_group("enemy"):
		var enemy_health_comp = pogo_target.get_node_or_null("HealthComponent")
		if enemy_health_comp:
			# MODIFIED: Pass `true` to bypass invincibility frames for pogo hits.
			enemy_health_comp.take_damage(1, owner_node, true)
			damage_dealt.emit()
	
	owner_node.velocity.y = -CombatDB.config.player_pogo_force
	owner_node.position.y -= 1
	p_data.can_dash = true
	p_data.air_jumps_left = CombatDB.config.player_max_air_jumps
	owner_node.change_state(owner_node.State.FALL)
