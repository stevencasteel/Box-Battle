# src/entities/player/player.gd
# This script is the "Context" for the State Machine. Its responsibilities are
# now almost entirely focused on managing the state machine and delegating
# work to its various components.
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
@onready var combat_component: CombatComponent = $CombatComponent
@onready var input_component: InputComponent = $InputComponent

# --- Preloads ---
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
	
	var player_health_configs = {
		"max_health": "player.health.max_health",
		"invincibility": "player.health.invincibility_duration",
		"knockback": {
			"speed": "player.combat.knockback_speed",
			"hazard_speed": "player.combat.hazard_knockback_speed"
		}
	}
	health_component.setup(p_data, self, player_health_configs)
	health_component.health_changed.connect(_on_health_component_health_changed)
	health_component.died.connect(_on_health_component_died)

	combat_component.setup(self, p_data)
	combat_component.damage_dealt.connect(_on_damage_dealt)
	
	input_component.setup(self, p_data, combat_component)

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
	input_component.process_physics()
	current_state.process_physics(delta)
	move_and_slide()
	_check_for_contact_damage()
	if is_on_wall() and not is_on_floor():
		p_data.wall_coyote_timer = Config.get_value("player.physics.wall_coyote_time")
		p_data.last_wall_normal = get_wall_normal()

func _unhandled_input(event: InputEvent):
	input_component.process_unhandled_input(event)
	
func _exit_tree():
	EventBus.off_owner(self)
	states.clear()
	p_data = null
	health_component = null
	combat_component = null
	input_component = null

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
		if col:
			var collider = col.get_collider()
			if collider.is_in_group("enemy") or collider.is_in_group("hazard"):
				var damage_result = health_component.take_damage(1, collider)
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

func _on_hitbox_body_entered(body):
	if p_data.is_pogo_attack:
		combat_component.trigger_pogo(body)
	elif body.is_in_group("enemy"):
		var enemy_health_comp = body.get_node_or_null("HealthComponent")
		if enemy_health_comp:
			# SOLUTION: Pass 'self' (the player) as the second argument.
			enemy_health_comp.take_damage(1, self)
			_on_damage_dealt()

func _on_hitbox_area_entered(area):
	if area.is_in_group("enemy_projectile"):
		if p_data.is_pogo_attack:
			combat_component.trigger_pogo(area)
		else:
			ObjectPool.return_instance(area)

func _on_hurtbox_area_entered(area):
	if area.is_in_group("enemy_projectile"):
		var damage_result = health_component.take_damage(1, area)
		if damage_result.was_damaged:
			velocity = damage_result.knockback_velocity
			change_state(State.HURT)
		ObjectPool.return_instance(area)

func _on_healing_timer_timeout():
	if states.find_key(current_state) == State.HEAL:
		p_data.health = min(p_data.health + 1, health_component.max_health)
		p_data.healing_charges -= 1
		health_component.health_changed.emit(p_data.health, health_component.max_health)
		_emit_healing_charges_changed_event()
		change_state(State.MOVE)

func _on_health_component_health_changed(current, max_val):
	var ev = PlayerHealthChangedEvent.new()
	ev.current_health = current
	ev.max_health = max_val
	EventBus.emit(EventCatalog.PLAYER_HEALTH_CHANGED, ev, self)
	health_changed.emit(current, max_val)

func _on_health_component_died():
	died.emit()