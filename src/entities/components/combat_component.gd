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

# MODIFIED: Signature now matches the parent ComponentInterface.
func setup(p_owner: Node, p_dependencies: Dictionary = {}) -> void:
	self.owner_node = p_owner as CharacterBody2D
	
	# Pull required dependencies from the dictionary.
	self.p_data = p_dependencies.get("data_resource")
	
	if not p_data:
		push_error("CombatComponent.setup: Missing required dependency ('data_resource').")
		return

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
	# CORRECTED: Fixed the typo from p_ogo_target to pogo_target.
	if not is_instance_valid(pogo_target):
		return false

	var should_bounce = false
	
	# Can bounce on projectiles.
	if p_data.is_pogo_attack and pogo_target.is_in_group("enemy_projectile"):
		should_bounce = true
		ObjectPool.return_instance(pogo_target)
	
	# Can bounce on enemies and deal damage.
	var damageable = CombatUtils.find_damageable(pogo_target)
	if damageable:
		should_bounce = true
		var damage_result = damageable.apply_damage(1, owner_node, true)
		if damage_result["was_damaged"]:
			damage_dealt.emit()

	# Can bounce on the ground or any solid world tile.
	if pogo_target is StaticBody2D and pogo_target.is_in_group("world"):
		should_bounce = true

	if should_bounce:
		pogo_bounce_requested.emit()
		return true

	return false
