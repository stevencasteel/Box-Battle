# src/entities/player/components/player_physics_component.gd
@tool
## Manages all direct physics interactions for the player character.
##
## Handles gravity, movement, collision detection, and applying velocity via
## move_and_slide(). It serves as the single point of contact with the
## Godot physics engine for the player.
class_name PlayerPhysicsComponent
extends ComponentInterface

# --- Member Variables ---
var owner_node: Player
var p_data: PlayerStateData

# --- Godot Lifecycle Methods ---

func _physics_process(_delta: float) -> void:
	owner_node.move_and_slide()
	_check_for_contact_damage()

	if owner_node.is_on_wall() and not owner_node.is_on_floor():
		p_data.wall_coyote_timer = p_data.config.player_wall_coyote_time
		p_data.last_wall_normal = owner_node.get_wall_normal()

# --- Public Methods ---

func setup(p_owner: Node, p_dependencies: Dictionary = {}) -> void:
	self.owner_node = p_owner as Player
	self.p_data = p_dependencies.get("data_resource")

func apply_horizontal_movement() -> void:
	var move_axis = owner_node.input_component.buffer.get("move_axis", 0.0)
	owner_node.velocity.x = move_axis * p_data.config.player_speed
	if not is_zero_approx(move_axis):
		p_data.facing_direction = sign(move_axis)

func apply_gravity(delta: float, multiplier: float = 1.0) -> void:
	owner_node.velocity.y += p_data.config.gravity * multiplier * delta

# --- Private Methods ---

func _check_for_contact_damage() -> void:
	if p_data.is_invincible: return
	for i in range(owner_node.get_slide_collision_count()):
		var col = owner_node.get_slide_collision(i)
		if not col: continue

		var collider = col.get_collider()
		var is_damage_source = is_instance_valid(collider) and \
			(collider.is_in_group(Identifiers.Groups.ENEMY) or collider.is_in_group(Identifiers.Groups.HAZARD))
		
		if not is_damage_source: continue

		var damage_info = DamageInfo.new()
		damage_info.amount = 1
		damage_info.source_node = collider
		var damage_result = owner_node.health_component.apply_damage(damage_info)

		if damage_result.was_damaged:
			owner_node.velocity = damage_result.knockback_velocity
			owner_node.state_machine.change_state(owner_node.State.HURT)
		break
