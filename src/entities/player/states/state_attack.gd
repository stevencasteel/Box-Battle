# src/entities/player/states/state_attack.gd
# Handles the player's melee attack.
extends PlayerState

func enter():
	p_data.attack_duration_timer = Config.get_value("player.combat.attack_duration")
	p_data.attack_cooldown_timer = Config.get_value("player.combat.attack_cooldown")
	player.hitbox_shape.disabled = false
	p_data.is_pogo_attack = false
	
	if Input.is_action_pressed("ui_down"):
		p_data.is_pogo_attack = true
		player.hitbox.position = Vector2(0, 60)
		
		if player.is_on_floor():
			# MODIFIED: Call the component's method
			player.combat_component.trigger_pogo(null)
			return
		
		if _check_for_immediate_pogo():
			return
			
	elif Input.is_action_pressed("ui_up"):
		player.hitbox.position = Vector2(0, -60)
	else:
		player.hitbox.position = Vector2(p_data.facing_direction * 60, 0)

func exit():
	player.hitbox_shape.call_deferred("set", "disabled", true)
	p_data.is_pogo_attack = false

func process_physics(delta: float):
	if not p_data.is_pogo_attack:
		var friction = Config.get_value("player.combat.attack_friction")
		player.velocity = player.velocity.move_toward(Vector2.ZERO, friction * delta)
	
	if p_data.attack_duration_timer <= 0:
		player.change_state(player.State.FALL)

func _check_for_immediate_pogo() -> bool:
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = player.hitbox_shape.shape
	query.transform = player.global_transform * player.hitbox.transform
	query.collision_mask = 2 | 4 | 8 | 16
	query.exclude = [player]
	
	var results = player.get_world_2d().direct_space_state.intersect_shape(query)
	
	if not results.is_empty():
		# MODIFIED: Call the component's method
		player.combat_component.trigger_pogo(results[0].collider)
		return true
		
	return false
