# src/entities/player/components/player_physics_component.gd
@tool
## Manages all direct physics interactions for the player character.
##
## Handles gravity, movement, collision detection, and applying velocity via
## move_and_slide(). It serves as the single point of contact with the
## Godot physics engine for the player.
class_name PlayerPhysicsComponent
extends IComponent

# --- Member Variables ---
var owner_node: Player
var p_data: PlayerStateData
var health_component: HealthComponent
var input_component: InputComponent

# --- Godot Lifecycle Methods ---


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(owner_node):
		return  # Guard against post-teardown calls

	owner_node.move_and_slide()
	_check_for_contact_damage()

	# GUARD: The owner may have been freed by the contact damage check.
	if not is_instance_valid(owner_node):
		return

	if owner_node.is_on_wall() and not owner_node.is_on_floor():
		p_data.wall_coyote_timer = p_data.config.player_wall_coyote_time
		p_data.last_wall_normal = owner_node.get_wall_normal()


# --- Public Methods ---


func setup(p_owner: Node, p_dependencies: Dictionary = {}) -> void:
	self.owner_node = p_owner as Player
	self.p_data = p_dependencies.get("data_resource")
	self.health_component = p_dependencies.get("health_component")
	self.input_component = p_dependencies.get("input_component")
	assert(is_instance_valid(input_component), "PlayerPhysicsComponent requires an InputComponent.")
	assert(is_instance_valid(health_component), "PlayerPhysicsComponent requires a HealthComponent.")


func teardown() -> void:
	set_physics_process(false)
	owner_node = null
	p_data = null
	health_component = null
	input_component = null


func apply_horizontal_movement() -> void:
	var move_axis = owner_node.get_component(InputComponent).buffer.get("move_axis", 0.0)
	owner_node.velocity.x = move_axis * p_data.config.player_speed
	if not is_zero_approx(move_axis):
		p_data.facing_direction = sign(move_axis)


func apply_gravity(delta: float, multiplier: float = 1.0) -> void:
	owner_node.velocity.y += p_data.config.gravity * multiplier * delta


## Checks if the conditions for performing a wall slide are met.
func can_wall_slide() -> bool:
	var ic: InputComponent = owner_node.get_component(InputComponent)
	var move_axis = ic.buffer.get("move_axis", 0.0)
	return (
		p_data.wall_coyote_timer > 0
		and not owner_node.is_on_floor()
		and move_axis != 0
		and sign(move_axis) == -p_data.last_wall_normal.x
	)


## Applies the velocity and resets timers for a wall jump.
func perform_wall_jump() -> void:
	owner_node.velocity.y = -p_data.config.player_wall_jump_force_y
	owner_node.velocity.x = p_data.last_wall_normal.x * p_data.config.player_wall_jump_force_x
	p_data.coyote_timer = 0
	p_data.wall_coyote_timer = 0


# --- Private Methods ---


func _check_for_contact_damage() -> void:
	if health_component.is_invincible():
		return

	for i in range(owner_node.get_slide_collision_count()):
		var col = owner_node.get_slide_collision(i)
		if not col:
			continue

		var collider = col.get_collider()
		var is_damage_source = (
			is_instance_valid(collider)
			and (
				collider.is_in_group(Identifiers.Groups.ENEMY)
				or collider.is_in_group(Identifiers.Groups.HAZARD)
			)
		)

		if not is_damage_source:
			continue

		var damage_info = DamageInfo.new()
		damage_info.amount = 1
		damage_info.source_node = collider
		damage_info.impact_position = col.get_position()
		damage_info.impact_normal = col.get_normal()
		# THE FIX: Use the local reference, not the owner's (which is gone).
		var damage_result = health_component.apply_damage(damage_info)

		# GUARD: The owner may have been freed by the apply_damage call.
		if not is_instance_valid(owner_node):
			return

		if damage_result.was_damaged and p_data.health > 0:
			owner_node.velocity = damage_result.knockback_velocity
			owner_node.get_component(BaseStateMachine).change_state(owner_node.State.HURT)
		break