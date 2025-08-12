# src/entities/player/states/state_attack.gd
# The pogo logic is now hardened to correctly find damageable targets
# even when hitting child colliders first.
extends BaseState

func enter(_msg := {}):
	state_data.is_pogo_attack = Input.is_action_pressed("ui_down")
	owner.hitbox_shape.disabled = false

	# --- UNIFIED POGO LOGIC ---
	if state_data.is_pogo_attack:
		owner.hitbox.position = Vector2(0, 60)
		
		# Always perform a physics check. If it fails, instantly cancel the attack.
		if not _check_for_immediate_pogo():
			state_machine.change_state(owner.State.FALL)
			return
	
	# --- MELEE ATTACK LOGIC ---
	else:
		state_data.attack_duration_timer = CombatDB.config.player_attack_duration
		state_data.attack_cooldown_timer = CombatDB.config.player_attack_cooldown
		
		if Input.is_action_pressed("ui_up"):
			owner.hitbox.position = Vector2(0, -60)
		else:
			owner.hitbox.position = Vector2(state_data.facing_direction * 60, 0)


func exit():
	owner.hitbox_shape.call_deferred("set", "disabled", true)
	state_data.is_pogo_attack = false

func process_physics(delta: float):
	if not state_data.is_pogo_attack:
		var friction = CombatDB.config.player_attack_friction
		owner.velocity = owner.velocity.move_toward(Vector2.ZERO, friction * delta)
	
	if state_data.attack_duration_timer <= 0:
		state_machine.change_state(owner.State.FALL)

# THE FIX: This function now iterates through all query results to find a valid target.
func _check_for_immediate_pogo() -> bool:
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = owner.hitbox_shape.shape
	query.transform = owner.global_transform * owner.hitbox.transform
	query.collision_mask = PhysicsLayers.WORLD | PhysicsLayers.ENEMY | PhysicsLayers.HAZARD | PhysicsLayers.ENEMY_PROJECTILE
	query.exclude = [owner]
	query.collide_with_areas = true
	
	# Get all potential targets from the physics space.
	var results = owner.get_world_2d().direct_space_state.intersect_shape(query)
	
	# If there are no results, we can stop immediately.
	if results.is_empty():
		return false
	
	# Loop through every collider the pogo check hit.
	for result in results:
		# Use our robust utility to find the actual damageable entity.
		# This correctly handles child collision shapes.
		var pogo_target = result.collider
		if owner.combat_component.trigger_pogo(pogo_target):
			# As soon as we successfully trigger a pogo, we're done.
			print("VERIFICATION: Pogo attack successfully triggered.")
			return true
	
	# If we looped through all results and none were valid pogo targets, fail.
	return false
