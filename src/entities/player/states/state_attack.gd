# src/entities/player/states/state_attack.gd
# This state now dynamically changes the hitbox shape for upward attacks,
# ensuring the correct behavior for all melee directions.
extends BaseState

# Pre-create the shape resources for performance.
const FORWARD_ATTACK_SHAPE = preload("res://src/entities/player/data/forward_attack_shape.tres")
const UPWARD_ATTACK_SHAPE = preload("res://src/entities/player/data/upward_attack_shape.tres")

func enter(_msg := {}):
	state_data.is_pogo_attack = owner.input_component.buffer.get("down")
	state_data.hit_targets_this_swing.clear()

	if state_data.is_pogo_attack:
		owner.pogo_hitbox.position = Vector2(0, 40)
		owner.pogo_hitbox_shape.disabled = false
		
		if not _check_for_immediate_pogo():
			state_machine.change_state(owner.State.FALL)
			return
	else:
		state_data.attack_duration_timer = state_data.config.player_attack_duration
		state_data.attack_cooldown_timer = state_data.config.player_attack_cooldown
		
		if owner.input_component.buffer.get("up"):
			owner.melee_hitbox_shape.shape = UPWARD_ATTACK_SHAPE
			owner.melee_hitbox_shape.position = Vector2(0, -40)
		else:
			owner.melee_hitbox_shape.shape = FORWARD_ATTACK_SHAPE
			owner.melee_hitbox_shape.position = Vector2(state_data.facing_direction * 60, 0)
		
		owner.melee_hitbox_shape.disabled = false

func exit():
	owner.melee_hitbox_shape.call_deferred("set", "disabled", true)
	owner.pogo_hitbox_shape.call_deferred("set", "disabled", true)
	state_data.is_pogo_attack = false
	state_data.hit_targets_this_swing.clear()

func process_physics(delta: float):
	if not state_data.is_pogo_attack:
		var friction = state_data.config.player_attack_friction
		owner.velocity = owner.velocity.move_toward(Vector2.ZERO, friction * delta)
	
	if state_data.attack_duration_timer <= 0:
		state_machine.change_state(owner.State.FALL)

func _check_for_immediate_pogo() -> bool:
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = owner.pogo_hitbox_shape.shape
	query.transform = owner.global_transform * owner.pogo_hitbox.transform
	query.collision_mask = PhysicsLayers.WORLD | PhysicsLayers.ENEMY | PhysicsLayers.HAZARD | PhysicsLayers.ENEMY_PROJECTILE
	query.exclude = [owner]
	query.collide_with_areas = true
	
	var results = owner.get_world_2d().direct_space_state.intersect_shape(query)
	
	if results.is_empty(): return false
	
	for result in results:
		var pogo_target = result.collider
		if owner.combat_component.trigger_pogo(pogo_target):
			return true
	
	return false
