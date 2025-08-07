# src/entities/player/player.gd
# This script is the "Context" for the State Machine. Its primary jobs are to:
# 1. Hold all shared player data (health, velocity, timers, etc.).
# 2. Manage the transitions between states.
# 3. Provide centralized helper functions for states to use (DRY principle).
extends CharacterBody2D

# --- Signals ---
signal health_changed(current_health, max_health)
signal healing_charges_changed(current_charges)
signal died

# --- REFINEMENT: The State enum is now globally accessible via Player.State ---
enum State {MOVE, JUMP, FALL, DASH, WALL_SLIDE, ATTACK, HURT, HEAL}

# --- Node References ---
@onready var visual_sprite: ColorRect = $ColorRect
@onready var hitbox: Area2D = $Hitbox
@onready var hurtbox: Area2D = $Hurtbox
@onready var invincibility_timer: Timer = $InvincibilityTimer
@onready var healing_timer: Timer = $HealingTimer
@onready var hit_flash_timer: Timer = $HitFlashTimer
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D

# --- Preloads ---
const PlayerShotScene = preload(AssetPaths.SCENE_PLAYER_SHOT)
const MoveState = preload("res://src/entities/player/states/state_move.gd")
const FallState = preload("res://src/entities/player/states/state_fall.gd")
const JumpState = preload("res://src/entities/player/states/state_jump.gd")
const DashState = preload("res://src/entities/player/states/state_dash.gd")
const WallSlideState = preload("res://src/entities/player/states/state_wall_slide.gd")
const AttackState = preload("res://src/entities/player/states/state_attack.gd")
const HurtState = preload("res://src/entities/player/states/state_hurt.gd")
const HealState = preload("res://src/entities/player/states/state_heal.gd")

# --- State Machine ---
var states: Dictionary
var current_state: PlayerState
const ACTION_ALLOWED_STATES = [State.MOVE, State.FALL, State.JUMP, State.WALL_SLIDE]

# --- Player Stats & Timers (Shared Data) ---
var health = Constants.PLAYER_MAX_HEALTH
var air_jumps_left = 0
var coyote_timer = 0.0
var jump_buffer_timer = 0.0
var wall_coyote_timer = 0.0
var knockback_timer = 0.0
var is_invincible = false
var is_dash_invincible = false
var facing_direction = 1
var last_wall_normal = Vector2.ZERO
var determination_counter = 0
var healing_charges = 0
var dash_duration_timer = 0.0
var dash_cooldown_timer = 0.0
var attack_duration_timer = 0.0
var attack_cooldown_timer = 0.0
var is_charging = false
var charge_timer = 0.0
var is_pogo_attack = false
var can_dash = true
var original_color: Color

# --- Engine Functions ---
func _ready():
	add_to_group("player")
	original_color = visual_sprite.color
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	health_changed.emit(health, Constants.PLAYER_MAX_HEALTH)
	healing_charges_changed.emit(healing_charges)
	states = {
		State.MOVE: MoveState.new(self), State.FALL: FallState.new(self),
		State.JUMP: JumpState.new(self), State.DASH: DashState.new(self),
		State.WALL_SLIDE: WallSlideState.new(self), State.ATTACK: AttackState.new(self),
		State.HURT: HurtState.new(self), State.HEAL: HealState.new(self),
	}
	current_state = states[State.FALL]
	current_state.enter()

func _physics_process(delta):
	_update_timers(delta)
	_poll_global_inputs()
	current_state.process_physics(delta)
	move_and_slide()
	_check_for_contact_damage()
	if is_on_wall() and not is_on_floor():
		wall_coyote_timer = Constants.WALL_COYOTE_TIME
		last_wall_normal = get_wall_normal()

func _unhandled_input(event: InputEvent):
	current_state.process_input(event)

func _update_timers(delta):
	coyote_timer = max(0.0, coyote_timer - delta)
	jump_buffer_timer = max(0.0, jump_buffer_timer - delta)
	dash_cooldown_timer = max(0.0, dash_cooldown_timer - delta)
	dash_duration_timer = max(0.0, dash_duration_timer - delta)
	attack_duration_timer = max(0.0, attack_duration_timer - delta)
	attack_cooldown_timer = max(0.0, attack_cooldown_timer - delta)
	knockback_timer = max(0.0, knockback_timer - delta)
	wall_coyote_timer = max(0.0, wall_coyote_timer - delta)
	if is_charging and Input.is_action_pressed("ui_attack"):
		charge_timer += delta

func _poll_global_inputs():
	if Input.is_action_just_pressed("ui_jump"):
		jump_buffer_timer = Constants.JUMP_BUFFER

	if not states.find_key(current_state) in ACTION_ALLOWED_STATES:
		return

	if Input.is_action_just_pressed("ui_attack") and attack_cooldown_timer <= 0:
		is_charging = true; charge_timer = 0.0
	
	if Input.is_action_just_released("ui_attack"):
		if is_charging:
			if charge_timer >= Constants.CHARGE_TIME: _fire_shot()
			else: change_state(State.ATTACK)
			is_charging = false
	
	if Input.is_action_just_pressed("ui_dash") and can_dash and dash_cooldown_timer <= 0:
		change_state(State.DASH)
		
	if is_on_floor() and Input.is_action_pressed("ui_down") and Input.is_action_pressed("ui_jump") and healing_charges > 0 and is_zero_approx(velocity.x):
		change_state(State.HEAL)

func change_state(new_state_key: State):
	if not states.has(new_state_key) or current_state == states[new_state_key]: return
	current_state.exit()
	current_state = states[new_state_key]
	current_state.enter()

# --- REFINEMENT: Centralized helper function for states (DRY Principle) ---
func apply_horizontal_movement():
	velocity.x = Input.get_axis("ui_left", "ui_right") * Constants.PLAYER_SPEED
	if not is_zero_approx(velocity.x):
		facing_direction = sign(velocity.x)

# --- Public Action & Helper Functions (Unchanged) ---
func take_damage(damage_amount: int, damage_source = null):
	if is_invincible or is_dash_invincible: return
	health -= damage_amount
	health_changed.emit(health, Constants.PLAYER_MAX_HEALTH)
	_trigger_hit_flash()
	is_invincible = true
	invincibility_timer.start(Constants.PLAYER_INVINCIBILITY_DURATION)
	if damage_source:
		var knockback_dir = (global_position - damage_source.global_position).normalized()
		var knockback_str = Constants.KNOCKBACK_SPEED
		if damage_source.is_in_group("hazard"): knockback_str = Constants.HAZARD_KNOCKBACK_SPEED
		velocity = (knockback_dir + Vector2.UP * 0.5).normalized() * knockback_str
	change_state(State.HURT)
	if health <= 0: die()

func die(): died.emit()

func _check_for_contact_damage():
	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i)
		if col and (col.get_collider().is_in_group("enemy") or col.get_collider().is_in_group("hazard")):
			take_damage(1, col.get_collider()); break

func _on_damage_dealt():
	if healing_charges >= Constants.PLAYER_MAX_HEALING_CHARGES: return
	determination_counter += 1
	if determination_counter >= Constants.DETERMINATION_PER_CHARGE:
		determination_counter = 0; healing_charges += 1
		healing_charges_changed.emit(healing_charges)

func _cancel_heal():
	if healing_timer.is_stopped(): return
	healing_timer.stop(); print("Healing canceled.")
	
func _trigger_hit_flash(): visual_sprite.color = Color.DODGER_BLUE

func _fire_shot():
	attack_cooldown_timer = Constants.ATTACK_COOLDOWN
	var shot_dir = Vector2(facing_direction, 0)
	if Input.is_action_pressed("ui_up"): shot_dir = Vector2.UP
	elif Input.is_action_pressed("ui_down"): shot_dir = Vector2.DOWN
	var shot = PlayerShotScene.instantiate(); shot.direction = shot_dir
	shot.position = global_position + (shot_dir * 60)
	get_parent().add_child(shot)

func _trigger_pogo(pogo_target):
	velocity.y = -Constants.POGO_FORCE
	position.y -= 1
	can_dash = true
	air_jumps_left = Constants.MAX_AIR_JUMPS
	change_state(State.FALL)
	if pogo_target:
		if pogo_target.has_method("take_damage"):
			pogo_target.take_damage(1); _on_damage_dealt()
		elif pogo_target.is_in_group("enemy_projectile"):
			pogo_target.queue_free()

# --- Signal Callbacks ---
func _on_hit_flash_timer_timeout(): visual_sprite.color = original_color

func _on_hitbox_body_entered(body):
	if is_pogo_attack: _trigger_pogo(body)
	elif body.is_in_group("enemy"): body.take_damage(1); _on_damage_dealt()

func _on_hitbox_area_entered(area):
	if area.is_in_group("enemy_projectile"):
		if is_pogo_attack: _trigger_pogo(area)
		else: area.queue_free()

func _on_hurtbox_area_entered(area):
	if area.is_in_group("enemy_projectile"): take_damage(1, area); area.queue_free()

func _on_invincibility_timer_timeout(): is_invincible = false

func _on_healing_timer_timeout():
	if states.find_key(current_state) == State.HEAL:
		health = min(health + 1, Constants.PLAYER_MAX_HEALTH); healing_charges -= 1
		health_changed.emit(health, Constants.PLAYER_MAX_HEALTH)
		healing_charges_changed.emit(healing_charges)
		change_state(State.MOVE)
