# src/entities/player/states/state_attack.gd
# Handles the player's melee attack.
extends PlayerState

func enter():
	p_data.is_pogo_attack = Input.is_action_pressed("ui_down")
	player.hitbox_shape.disabled = false

	# --- UNIFIED POGO LOGIC ---
	if p_data.is_pogo_attack:
		player.hitbox.position = Vector2(0, 60)
		
		# Always perform a physics check. If it fails, instantly cancel the attack.
		# This single check now handles ground, air, and enemy pogos.
		if not _check_for_immediate_pogo():
			player.change_state(player.State.FALL)
			return
	
	# --- MELEE ATTACK LOGIC ---
	else:
		p_data.attack_duration_timer = CombatDB.config.player_attack_duration
		p_data.attack_cooldown_timer = CombatDB.config.player_attack_cooldown
		
		if Input.is_action_pressed("ui_up"):
			player.hitbox.position = Vector2(0, -60)
		else:
			player.hitbox.position = Vector2(p_data.facing_direction * 60, 0)


func exit():
	player.hitbox_shape.call_deferred("set", "disabled", true)
	p_data.is_pogo_attack = false

func process_physics(delta: float):
	if not p_data.is_pogo_attack:
		var friction = CombatDB.config.player_attack_friction
		player.velocity = player.velocity.move_toward(Vector2.ZERO, friction * delta)
	
	if p_data.attack_duration_timer <= 0:
		player.change_state(player.State.FALL)

func _check_for_immediate_pogo() -> bool:
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = player.hitbox_shape.shape
	query.transform = player.global_transform * player.hitbox.transform
	query.collision_mask = PhysicsLayers.WORLD | PhysicsLayers.ENEMY | PhysicsLayers.HAZARD | PhysicsLayers.ENEMY_PROJECTILE
	query.exclude = [player]
	
	# CRITICAL FIX: Explicitly enable collision with Area2D nodes.
	query.collide_with_areas = true
	
	var results = player.get_world_2d().direct_space_state.intersect_shape(query)
	
	if not results.is_empty():
		if player.combat_component.trigger_pogo(results[0].collider):
			return true
	
	return false
