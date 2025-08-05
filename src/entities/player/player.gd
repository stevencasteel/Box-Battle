# src/entities/player/player.gd
#
# This script defines the player's complete behavior using a finite state machine
# to manage its actions like moving, jumping, dashing, and attacking.
extends CharacterBody2D

# --- Node References ---
@onready var hitbox: Area2D = $Hitbox
@onready var hurtbox: Area2D = $Hurtbox
@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var healing_timer: Timer = $HealingTimer
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D

# --- Preloads ---
const PlayerShotScene = preload(AssetPaths.SCENE_PLAYER_SHOT)

# --- State Machine ---
enum State {MOVE, JUMP, FALL, DASH, WALL_SLIDE, ATTACK, HURT, HEAL}
var state: State = State.FALL

# --- Player Stats & Timers ---
var health = Constants.PLAYER_MAX_HEALTH
var air_jumps_left = 0
var coyote_timer = 0.0
var jump_buffer_timer = 0.0
var wall_coyote_timer = 0.0
var knockback_timer = 0.0
var is_invincible = false
var facing_direction = 1
var last_wall_normal = Vector2.ZERO

# --- NEW: Healing & Determination ---
var determination_counter = 0
var healing_charges = 0

# Attack and Dash Timers
var dash_duration_timer = 0.0
var dash_cooldown_timer = 0.0
var attack_duration_timer = 0.0
var attack_cooldown_timer = 0.0
var is_charging = false
var charge_timer = 0.0
var is_pogo_attack = false
var can_dash = true


# --- Engine Functions ---

func _ready():
	add_to_group("player")
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	# The body_entered signal for the hurtbox is no longer needed.
	# If it's still connected in the editor, it will now point to a non-existent function,
	# which is harmless but can be disconnected in the editor for ultimate cleanliness.


func _physics_process(delta):
	# --- Update Timers ---
	coyote_timer = max(0.0, coyote_timer - delta)
	jump_buffer_timer = max(0.0, jump_buffer_timer - delta)
	dash_cooldown_timer = max(0.0, dash_cooldown_timer - delta)
	dash_duration_timer = max(0.0, dash_duration_timer - delta)
	attack_duration_timer = max(0.0, attack_duration_timer - delta)
	attack_cooldown_timer = max(0.0, attack_cooldown_timer - delta)
	knockback_timer = max(0.0, knockback_timer - delta)
	wall_coyote_timer = max(0.0, wall_coyote_timer - delta)

	# --- Handle Global Inputs ---
	_handle_input(delta)

	# --- State Machine Logic (calculates velocity) ---
	match state:
		State.MOVE: state_move(delta)
		State.JUMP: state_jump(delta)
		State.FALL: state_fall(delta)
		State.DASH: state_dash()
		State.WALL_SLIDE: state_wall_slide()
		State.ATTACK: state_attack()
		State.HURT: state_hurt(delta)
		State.HEAL: state_heal()

	move_and_slide()
	
	_check_for_contact_damage()
	
	if is_on_wall():
		wall_coyote_timer = Constants.WALL_COYOTE_TIME
		last_wall_normal = get_wall_normal()


func _handle_input(delta):
	if Input.is_action_just_pressed("ui_jump"):
		jump_buffer_timer = Constants.JUMP_BUFFER

	# Only check for attacks if not already in an uninterruptible state.
	if state in [State.ATTACK, State.HURT, State.HEAL]: return
	
	if Input.is_action_just_pressed("ui_attack") and attack_cooldown_timer <= 0:
		is_charging = true; charge_timer = 0.0
	if is_charging and Input.is_action_pressed("ui_attack"):
		charge_timer += delta
	if Input.is_action_just_released("ui_attack"):
		if is_charging:
			if charge_timer >= Constants.CHARGE_TIME: _fire_shot()
			else: change_state(State.ATTACK)
			is_charging = false

# --- State Functions ---

func state_move(delta):
	coyote_timer = Constants.COYOTE_TIME
	
	# Check for healing input
	var is_holding_heal = Input.is_action_pressed("ui_down") and Input.is_action_pressed("ui_jump")
	if is_holding_heal and healing_charges > 0:
		change_state(State.HEAL)
		return # Stop processing in this state
		
	_apply_horizontal_movement()
	velocity.y += Constants.GRAVITY * delta
	if not is_on_floor(): change_state(State.FALL)
	if jump_buffer_timer > 0: _perform_jump()

	if Input.is_action_just_pressed("ui_dash") and can_dash and dash_cooldown_timer <= 0:
		change_state(State.DASH)

func state_jump(delta):
	_apply_horizontal_movement()
	_apply_gravity(delta)
	_check_for_landing()
	_check_for_wall_slide()

	if Input.is_action_just_pressed("ui_dash") and can_dash and dash_cooldown_timer <= 0:
		change_state(State.DASH)
	
	if jump_buffer_timer > 0 and air_jumps_left > 0:
		_perform_air_jump()

func state_fall(delta):
	_apply_horizontal_movement()
	_apply_gravity(delta)
	_check_for_landing()
	_check_for_wall_slide()

	if jump_buffer_timer > 0:
		if wall_coyote_timer > 0: _perform_wall_jump()
		elif coyote_timer > 0: _perform_jump()
		elif air_jumps_left > 0: _perform_air_jump()
		
	if Input.is_action_just_pressed("ui_dash") and can_dash and dash_cooldown_timer <= 0:
		change_state(State.DASH)

func state_wall_slide():
	velocity.y = min(velocity.y + Constants.GRAVITY * get_physics_process_delta_time(), Constants.WALL_SLIDE_SPEED)
	facing_direction = -last_wall_normal.x

	if jump_buffer_timer > 0:
		_perform_wall_jump(); return

	if Input.get_axis("ui_left", "ui_right") * -last_wall_normal.x < 0.8:
		change_state(State.FALL)
	if wall_coyote_timer <= 0:
		change_state(State.FALL)
	if is_on_floor():
		change_state(State.MOVE)

func state_dash():
	velocity = _get_dash_direction() * Constants.DASH_SPEED
	if dash_duration_timer <= 0: velocity = Vector2.ZERO; change_state(State.FALL)

func state_attack():
	velocity = Vector2.ZERO
	if attack_duration_timer <= 0:
		hitbox_shape.call_deferred("set", "disabled", true); is_pogo_attack = false
		change_state(State.FALL)

func state_hurt(delta):
	velocity.y += Constants.GRAVITY * delta
	if knockback_timer <= 0: change_state(State.FALL)

# --- NEW: Healing State Logic ---
func state_heal():
	velocity = Vector2.ZERO
	
	var is_holding_heal = Input.is_action_pressed("ui_down") and Input.is_action_pressed("ui_jump")
	var moved = not is_zero_approx(Input.get_axis("ui_left", "ui_right"))
	
	if not is_holding_heal or moved or not is_on_floor():
		_cancel_heal()
		change_state(State.MOVE) # Transition to move after canceling

# --- State Change & Helper Functions ---

func change_state(new_state: State):
	if state == new_state: return
	
	if state == State.WALL_SLIDE:
		if last_wall_normal != Vector2.ZERO:
			facing_direction = last_wall_normal.x
	
	state = new_state
	match state:
		State.JUMP:
			jump_buffer_timer = 0; coyote_timer = 0
			velocity.y = -Constants.PLAYER_JUMP_FORCE
		State.DASH:
			can_dash = false
			dash_duration_timer = Constants.DASH_DURATION
			dash_cooldown_timer = Constants.DASH_COOLDOWN
		State.ATTACK:
			_perform_melee_attack()
		State.WALL_SLIDE:
			can_dash = true
			air_jumps_left = Constants.MAX_AIR_JUMPS
		State.HURT:
			is_charging = false
			_cancel_heal() # Cancel heal if you get hurt
			knockback_timer = Constants.KNOCKBACK_DURATION
		State.HEAL:
			healing_timer.start(Constants.PLAYER_HEAL_DURATION)
			print("Healing started...")


func _apply_horizontal_movement():
	if state in [State.DASH, State.HURT, State.ATTACK, State.WALL_SLIDE, State.HEAL]: return
	var input_direction = Input.get_axis("ui_left", "ui_right")
	velocity.x = input_direction * Constants.PLAYER_SPEED
	if input_direction != 0: facing_direction = sign(input_direction)

func _apply_gravity(delta):
	if velocity.y < 0 and Input.is_action_just_released("ui_jump"):
		velocity.y *= Constants.JUMP_RELEASE_DAMPENER
	velocity.y += Constants.GRAVITY * delta
	if state == State.JUMP and velocity.y > 0.0:
		change_state(State.FALL)

func _check_for_landing():
	if is_on_floor() and state in [State.FALL, State.JUMP]:
		can_dash = true
		air_jumps_left = Constants.MAX_AIR_JUMPS
		change_state(State.MOVE)

func _check_for_wall_slide():
	if state != State.JUMP and state != State.FALL:
		return
		
	var input_dir = Input.get_axis("ui_left", "ui_right")
	if wall_coyote_timer > 0 and not is_on_floor() and input_dir != 0 and sign(input_dir) == -last_wall_normal.x:
		change_state(State.WALL_SLIDE)

func _get_dash_direction():
	if Input.is_action_pressed("ui_up"): return Vector2.UP
	if Input.is_action_pressed("ui_down"): return Vector2.DOWN
	return Vector2(facing_direction, 0)

# --- Action Functions ---

func _perform_jump():
	change_state(State.JUMP)

func _perform_air_jump():
	velocity.y = -Constants.PLAYER_JUMP_FORCE
	air_jumps_left -= 1
	jump_buffer_timer = 0

func _perform_wall_jump():
	velocity.y = -Constants.WALL_JUMP_FORCE_Y
	velocity.x = last_wall_normal.x * Constants.WALL_JUMP_FORCE_X
	state = State.JUMP
	jump_buffer_timer = 0
	coyote_timer = 0
	wall_coyote_timer = 0

func _perform_melee_attack():
	attack_duration_timer = Constants.ATTACK_DURATION
	attack_cooldown_timer = Constants.ATTACK_COOLDOWN
	hitbox_shape.disabled = false
	is_pogo_attack = false
	if Input.is_action_pressed("ui_down"):
		is_pogo_attack = true; hitbox.position = Vector2(0, 60)
		# Call the new check. If it succeeds, the pogo is handled instantly.
		if _check_for_immediate_pogo():
			return # Stop here, the pogo was triggered.
	elif Input.is_action_pressed("ui_up"):
		hitbox.position = Vector2(0, -60)
	else:
		hitbox.position = Vector2(facing_direction * 60, 0)

func _fire_shot():
	attack_cooldown_timer = Constants.ATTACK_COOLDOWN
	var shot_direction = Vector2(facing_direction, 0)
	if Input.is_action_pressed("ui_up"): shot_direction = Vector2.UP
	elif Input.is_action_pressed("ui_down"): shot_direction = Vector2.DOWN
	var shot_instance = PlayerShotScene.instantiate()
	shot_instance.direction = shot_direction
	shot_instance.position = global_position + (shot_direction * 60)
	get_parent().add_child(shot_instance)

func _check_for_immediate_pogo() -> bool:
	# Proactively checks if the pogo hitbox is already overlapping a valid surface.
	var space_state = get_world_2d().direct_space_state
	var hitbox_shape_res = hitbox_shape.shape
	
	var query = PhysicsShapeQueryParameters2D.new()
	query.shape = hitbox_shape_res
	query.transform = hitbox.global_transform
	# Check against world (2), enemy (4), and hazard (8) layers.
	query.collision_mask = 14
	
	var results = space_state.intersect_shape(query)
	
	if not results.is_empty():
		_trigger_pogo(results[0].collider)
		return true # Signal success
	
	return false # Signal failure

func _trigger_pogo(pogo_target):
	# This is now the single source of truth for all pogo actions.
	hitbox_shape.call_deferred("set", "disabled", true) # Disable hitbox after one hit.
	is_pogo_attack = false # Ensure we don't pogo twice.
	
	can_dash = true
	velocity.y = -Constants.POGO_FORCE
	air_jumps_left = Constants.MAX_AIR_JUMPS
	dash_duration_timer = 0
	change_state(State.FALL) # Force state to FALL to re-evaluate logic.
	
	# --- POGO TARGET LOGIC ---
	# Check if we hit a valid pogo target.
	if pogo_target:
		# If it's an enemy, deal damage and gain determination.
		if pogo_target.has_method("take_damage"):
			pogo_target.take_damage(1)
			_on_damage_dealt()
		# If it's a projectile, destroy it.
		elif pogo_target.is_in_group("enemy_projectile"):
			pogo_target.queue_free()

func take_damage(damage_amount: int, damage_source = null):
	if is_invincible: return
	health -= damage_amount
	print("Player took %s damage! Health: %s" % [damage_amount, health])
	is_invincible = true
	invincibility_timer.start(Constants.PLAYER_INVINCIBILITY_DURATION)
	change_state(State.HURT)
	if damage_source:
		var knockback_direction = (global_position - damage_source.global_position).normalized()
		var knockback_strength = Constants.KNOCKBACK_SPEED
		if damage_source.is_in_group("hazard"): knockback_strength = Constants.HAZARD_KNOCKBACK_SPEED
		velocity = (knockback_direction + Vector2.UP * 0.5).normalized() * knockback_strength
	if health <= 0: die()

func die():
	print("Player has been defeated! Reloading stage.")
	get_tree().call_deferred("reload_current_scene")

func _check_for_contact_damage():
	for i in range(get_slide_collision_count()):
		var collision = get_slide_collision(i)
		if not collision: continue

		var body_hit = collision.get_collider()
		if not body_hit: continue

		if body_hit.is_in_group("enemy") or body_hit.is_in_group("hazard"):
			take_damage(1, body_hit)
			break

func _on_damage_dealt():
	if healing_charges >= Constants.PLAYER_MAX_HEALING_CHARGES:
		return

	determination_counter += 1
	print("Determination: %d/%d" % [determination_counter, Constants.DETERMINATION_PER_CHARGE])
	if determination_counter >= Constants.DETERMINATION_PER_CHARGE:
		determination_counter = 0
		healing_charges += 1
		print("Healing charge gained! Total charges: %d" % healing_charges)

func _cancel_heal():
	if healing_timer.is_stopped(): return
	healing_timer.stop()
	print("Healing canceled.")


# --- Signal Callbacks ---

func _on_hitbox_body_entered(body):
	if is_pogo_attack: 
		# Let the centralized pogo function handle all the logic.
		_trigger_pogo(body)
	elif body.is_in_group("enemy"):
		body.take_damage(1)
		_on_damage_dealt()
		hitbox_shape.call_deferred("set", "disabled", true)

func _on_hitbox_area_entered(area):
	if is_pogo_attack and area.is_in_group("enemy_projectile"): _trigger_pogo(area)

func _on_hurtbox_area_entered(area):
	if area.is_in_group("enemy_projectile"):
		take_damage(1, area); area.queue_free()

func _on_invincibility_timer_timeout():
	is_invincible = false

func _on_healing_timer_timeout():
	if state == State.HEAL:
		health = min(health + 1, Constants.PLAYER_MAX_HEALTH)
		healing_charges -= 1
		print("Healing successful! Health: %d. Charges left: %d" % [health, healing_charges])
		change_state(State.MOVE)
