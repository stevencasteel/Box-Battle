# src/entities/components/combat_component.gd
#
# A component that handles the execution of the player's combat abilities,
# such as firing projectiles and performing pogo attacks.
class_name CombatComponent
extends Node

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
	p_data.attack_cooldown_timer = Config.get_value("player.combat.attack_cooldown")
	
	var shot = ObjectPool.get_instance(&"player_shots")
	if not shot: return
	
	var shot_dir = Vector2(p_data.facing_direction, 0)
	if Input.is_action_pressed("ui_up"): shot_dir = Vector2.UP
	elif Input.is_action_pressed("ui_down"): shot_dir = Vector2.DOWN
	
	shot.direction = shot_dir
	shot.global_position = owner_node.global_position + (shot_dir * 60)
	shot.activate()

func trigger_pogo(pogo_target):
	owner_node.velocity.y = -Config.get_value("player.physics.pogo_force")
	owner_node.position.y -= 1
	p_data.can_dash = true
	p_data.air_jumps_left = Config.get_value("player.physics.max_air_jumps")
	owner_node.change_state(owner_node.State.FALL)
	
	# CORRECTED: Fixed the typo from "p_ogo_target" to "pogo_target".
	if pogo_target:
		if pogo_target.has_method("take_damage"):
			pogo_target.take_damage(1)
			# The owner is still responsible for its own game logic (like gaining charges).
			owner_node._on_damage_dealt() 
		elif pogo_target.is_in_group("enemy_projectile"):
			ObjectPool.return_instance(pogo_target)