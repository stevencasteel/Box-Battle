# src/entities/player/states/state_attack.gd
## This state handles the player's melee and pogo attacks.
class_name PlayerStateAttack
extends BaseState

# --- State Lifecycle ---

func enter(_msg := {}) -> void:
	state_data.is_pogo_attack = owner.input_component.buffer.get("down", false)
	state_data.hit_targets_this_swing.clear()

	if state_data.is_pogo_attack:
		owner.enable_pogo_hitbox(true)
		if not _check_for_immediate_pogo():
			state_machine.change_state(owner.State.FALL)
			return
	else:
		state_data.attack_duration_timer = state_data.config.player_attack_duration
		state_data.attack_cooldown_timer = state_data.config.player_attack_cooldown
		var is_up_attack = owner.input_component.buffer.get("up", false)
		owner.enable_melee_hitbox(true, is_up_attack)

func exit() -> void:
	owner.call_deferred("enable_melee_hitbox", false)
	owner.call_deferred("enable_pogo_hitbox", false)
	state_data.is_pogo_attack = false
	state_data.hit_targets_this_swing.clear()

func process_physics(delta: float) -> void:
	if not state_data.is_pogo_attack:
		var friction = state_data.config.player_attack_friction
		owner.velocity = owner.velocity.move_toward(Vector2.ZERO, friction * delta)

	if state_data.attack_duration_timer <= 0:
		state_machine.change_state(owner.State.FALL)

# --- Private Methods ---

func _check_for_immediate_pogo() -> bool:
	var pogo_hitbox: Area2D = owner.pogo_hitbox
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = pogo_hitbox.get_node("CollisionShape2D").shape
	query.transform = owner.global_transform * pogo_hitbox.transform
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
