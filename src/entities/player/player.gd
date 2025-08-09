# src/entities/player/player.gd
# This script is the "Context" for the State Machine. Its responsibilities
# have been reduced to managing the state machine, handling inputs, and
# coordinating its components.
extends CharacterBody2D

# --- Signals ---
signal health_changed(current_health, max_health)
signal healing_charges_changed(current_charges)
signal died

# --- State Enum ---
enum State {MOVE, JUMP, FALL, DASH, WALL_SLIDE, ATTACK, HURT, HEAL}

# --- Node References ---
@onready var visual_sprite: ColorRect = $ColorRect
@onready var hitbox: Area2D = $Hitbox
@onready var hurtbox: Area2D = $Hurtbox
@onready var healing_timer: Timer = $HealingTimer
@onready var hitbox_shape: CollisionShape2D = $Hitbox/CollisionShape2D
@onready var health_component: HealthComponent = $HealthComponent

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

# --- State Machine & Data ---
var states: Dictionary
var current_state: PlayerState
var p_data: PlayerStateData
const ACTION_ALLOWED_STATES = [State.MOVE, State.FALL, State.JUMP, State.WALL_SLIDE]

# --- Engine Functions ---
func _ready():
	p_data = PlayerStateData.new()
	
	visual_sprite.color = Palette.COLOR_PLAYER
	
	add_to_group("player")
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	
	health_component.setup(p_data, self)
	health_component.health_changed.connect(_on_health_component_health_changed)
	health_component.died.connect(_on_health_component_died)

	states = {
		State.MOVE: MoveState.new(self, p_data), State.FALL: FallState.new(self, p_data),
		State.JUMP: JumpState.new(self, p_data), State.DASH: DashState.new(self, p_data),
		State.WALL_SLIDE: WallSlideState.new(self, p_data), State.ATTACK: AttackState.new(self, p_data),
		State.HURT: HurtState.new(self, p_data), State.HEAL: HealState.new(self, p_data),
	}
	current_state = states[State.FALL]
	current_state.enter()
	
	_emit_healing_charges_changed_event()

func _physics_process(delta):
	_update_timers(delta)
	_poll_global_inputs()
	current_state.process_physics(delta)
	move_and_slide()
	_check_for_contact_damage()
	if is_on_wall() and not is_on_floor():
		p_data.wall_coyote_timer = Config.get_value("player.physics.wall_coyote_time")
		p_data.last_wall_normal = get_wall_normal()

func _unhandled_input(event: InputEvent):
	current_state.process_input(event)
	
func _exit_tree():
	# NEW: Unsubscribe this node from all EventBus events.
	EventBus.off_owner(self)
	
	states.clear()
	p_data = null
	health_component = null

func _update_timers(delta):
	p_data.coyote_timer = max(0.0, p_data.coyote_timer - delta)
	p_data.jump_buffer_timer = max(0.0, p_data.jump_buffer_timer - delta)
	p_data.dash_cooldown_timer = max(0.0, p_data.dash_cooldown_timer - delta)
	p_data.dash_duration_timer = max(0.0, p_data.dash_duration_timer - delta)
	p_data.attack_duration_timer = max(0.0, p_data.attack_duration_timer - delta)
	p_data.attack_cooldown_timer = max(0.0, p_data.attack_cooldown_timer - delta)
	p_data.knockback_timer = max(0.0, p_data.knockback_timer - delta)
	p_data.wall_coyote_timer = max(0.0, p_data.wall_coyote_timer - delta)
	if p_data.is_charging and Input.is_action_pressed("ui_attack"):
		p_data.charge_timer += delta

func _poll_global_inputs():
	if Input.is_action_just_pressed("ui_jump"):
		p_data.jump_buffer_timer = Config.get_value("player.physics.jump_buffer")
	if not states.find_key(current_state) in ACTION_ALLOWED_STATES: return
	if Input.is_action_just_pressed("ui_attack") and p_data.attack_cooldown_timer <= 0:
		p_data.is_charging = true; p_data.charge_timer = 0.0
	if Input.is_action_just_released("ui_attack"):
		if p_data.is_charging:
			if p_data.charge_timer >= Config.get_value("player.combat.charge_time"): _fire_shot()
			else: change_state(State.ATTACK)
			p_data.is_charging = false
	if Input.is_action_just_pressed("ui_dash") and p_data.can_dash and p_data.dash_cooldown_timer <= 0:
		change_state(State.DASH)
	if is_on_floor() and Input.is_action_pressed("ui_down") and Input.is_action_pressed("ui_jump") and p_data.healing_charges > 0 and is_zero_approx(velocity.x):
		change_state(State.HEAL)

func change_state(new_state_key: State):
	if not states.has(new_state_key) or current_state == states[new_state_key]: return
	current_state.exit()
	current_state = states[new_state_key]
	current_state.enter()

func apply_horizontal_movement():
	velocity.x = Input.get_axis("ui_left", "ui_right") * Config.get_value("player.physics.speed")
	if not is_zero_approx(velocity.x):
		p_data.facing_direction = sign(velocity.x)

func _emit_healing_charges_changed_event():
	var ev = PlayerHealingChargesChangedEvent.new()
	ev.current_charges = p_data.healing_charges
	EventBus.emit(EventCatalog.PLAYER_HEALING_CHARGES_CHANGED, ev, self)
	healing_charges_changed.emit(p_data.healing_charges)

func _check_for_contact_damage():
	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i)
		if col and (col.get_collider().is_in_group("enemy") or col.get_collider().is_in_group("hazard")):
			var damage_result = health_component.take_damage(1, col.get_collider())
			if damage_result.was_damaged:
				velocity = damage_result.knockback_velocity
				change_state(State.HURT)
			break

func _on_damage_dealt():
	if p_data.healing_charges >= Config.get_value("player.health.max_healing_charges"): return
	p_data.determination_counter += 1
	if p_data.determination_counter >= Config.get_value("player.combat.determination_per_charge"):
		p_data.determination_counter = 0; p_data.healing_charges += 1
		_emit_healing_charges_changed_event()

func _cancel_heal():
	if healing_timer.is_stopped(): return
	healing_timer.stop()
	
func _fire_shot():
	p_data.attack_cooldown_timer = Config.get_value("player.combat.attack_cooldown")
	var shot_dir = Vector2(p_data.facing_direction, 0)
	if Input.is_action_pressed("ui_up"): shot_dir = Vector2.UP
	elif Input.is_action_pressed("ui_down"): shot_dir = Vector2.DOWN
	var shot = PlayerShotScene.instantiate(); shot.direction = shot_dir
	shot.position = global_position + (shot_dir * 60)
	get_parent().add_child(shot)

func _trigger_pogo(pogo_target):
	velocity.y = -Config.get_value("player.physics.pogo_force")
	position.y -= 1; p_data.can_dash = true
	p_data.air_jumps_left = Config.get_value("player.physics.max_air_jumps")
	change_state(State.FALL)
	if pogo_target:
		if pogo_target.has_method("take_damage"):
			pogo_target.take_damage(1); _on_damage_dealt()
		elif pogo_target.is_in_group("enemy_projectile"):
			pogo_target.queue_free()

func _on_hitbox_body_entered(body):
	if p_data.is_pogo_attack: _trigger_pogo(body)
	elif body.is_in_group("enemy"): body.take_damage(1); _on_damage_dealt()

func _on_hitbox_area_entered(area):
	if area.is_in_group("enemy_projectile"):
		if p_data.is_pogo_attack: _trigger_pogo(area)
		else: area.queue_free()

func _on_hurtbox_area_entered(area):
	if area.is_in_group("enemy_projectile"):
		var damage_result = health_component.take_damage(1, area)
		if damage_result.was_damaged:
			velocity = damage_result.knockback_velocity
			change_state(State.HURT)
		area.queue_free()

func _on_healing_timer_timeout():
	if states.find_key(current_state) == State.HEAL:
		p_data.health = min(p_data.health + 1, health_component.max_health)
		p_data.healing_charges -= 1
		health_component.health_changed.emit(p_data.health, health_component.max_health)
		_emit_healing_charges_changed_event()
		change_state(State.MOVE)

# --- Signal handlers for HealthComponent ---
func _on_health_component_health_changed(current, max_val):
	var ev = PlayerHealthChangedEvent.new()
	ev.current_health = current
	ev.max_health = max_val
	EventBus.emit(EventCatalog.PLAYER_HEALTH_CHANGED, ev, self)
	health_changed.emit(current, max_val)

func _on_health_component_died():
	died.emit()
