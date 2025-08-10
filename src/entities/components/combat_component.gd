# src/entities/components/combat_component.gd
#
# A component that handles the execution of the player's combat abilities,
# such as firing projectiles and performing pogo attacks.
class_name CombatComponent
extends Node

signal damage_dealt

# --- Dependencies ---
var owner_node: CharacterBody2D
var p_data: PlayerStateData

# This setup function is called by the owner (the Player) to provide the
# component with the references it needs to do its job.
func setup(p_owner_node: CharacterBody2D, player_data: PlayerStateData):
	self.owner_node = p_owner_node
	self.p_data = player_data

# --- Public Combat Methods ---

func fire_shot():
	# MODIFIED: Get value from the new CombatDB resource.
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
	# MODIFIED: Get values from the new CombatDB resource.
	owner_node.velocity.y = -CombatDB.config.player_pogo_force
	owner_node.position.y -= 1
	p_data.can_dash = true
	p_data.air_jumps_left = CombatDB.config.player_max_air_jumps
	owner_node.change_state(owner_node.State.FALL)
	
	if pogo_target:
		if pogo_target.is_in_group("enemy"):
			var enemy_health_comp = pogo_target.get_node_or_null("HealthComponent")
			if enemy_health_comp:
				# SOLUTION: Pass 'owner_node' (the player) as the second argument.
				enemy_health_comp.take_damage(1, owner_node)
				damage_dealt.emit()
		elif pogo_target.is_in_group("enemy_projectile"):
			ObjectPool.return_instance(pogo_target)