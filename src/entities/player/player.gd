# src/entities/player/player.gd
# This script is the "Context" for the State Machine.
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

# --- State Scripts (Loaded at Runtime) ---
var MoveStateScript: Script
var FallStateScript: Script
var JumpStateScript: Script
var DashStateScript: Script
var WallSlideStateScript: Script
var AttackStateScript: Script
var HurtStateScript: Script
var HealStateScript: Script

# --- State Machine & Data ---
var states: Dictionary
var current_state: PlayerState
var p_data: PlayerStateData
const ACTION_ALLOWED_STATES = [State.MOVE, State.FALL, State.JUMP, State.WALL_SLIDE]

# --- Engine Functions ---
func _ready():
	p_data = PlayerStateData.new()
	
	MoveStateScript = load("res://src/entities/player/states/state_move.gd")
	FallStateScript = load("res://src/entities/player/states/state_fall.gd")
	JumpStateScript = load("res://src/entities/player/states/state_jump.gd")
	DashStateScript = load("res://src/entities/player/states/state_dash.gd")
	WallSlideStateScript = load("res://src/entities/player/states/state_wall_slide.gd")
	AttackStateScript = load("res://src/entities/player/states/state_attack.gd")
	HurtStateScript = load("res://src/entities/player/states/state_hurt.gd")
	HealStateScript = load("res://src/entities/player/states/state_heal.gd")

	states = {
		State.MOVE: MoveStateScript.new(self, p_data),
		State.FALL: FallStateScript.new(self, p_data),
		State.JUMP: JumpStateScript.new(self, p_data),
		State.DASH: DashStateScript.new(self, p_data),
		State.WALL_SLIDE: WallSlideStateScript.new(self, p_data),
		State.ATTACK: AttackStateScript.new(self, p_data),
		State.HURT: HurtStateScript.new(self, p_data),
		State.HEAL: HealStateScript.new(self, p_data),
	}

	visual_sprite.color = Palette.COLOR_PLAYER
	
	add_to_group("player")
	hitbox.body_entered.connect(_on_hitbox_body_entered)
	hitbox.area_entered.connect(_on_hitbox_area_entered)
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	
	health_component.setup(self, CombatDB.config)
	combat_component.setup(self)
	input_component.setup(self, null, null, combat_component)

	health_component.health_changed.connect(_on_health_component_health_changed)
	health_component.died.connect(_on_health_component_died)
	combat_component.damage_dealt.connect(_on_damage_dealt)

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
		p_data.wall_coyote_timer = CombatDB.config.player_wall_coyote_time
		p_data.last_wall_normal = get_wall_normal()

func _unhandled_input(event: InputEvent):
	input_component.process_unhandled_input(event)
	
func _exit_tree():
	states.clear()
	p_data = null
	
	if health_component: health_component.teardown()
	if combat_component: combat_component.teardown()
	if input_component: input_component.teardown()

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
	velocity.x = Input.get_axis("ui_left", "ui_right") * CombatDB.config.player_speed
	if not is_zero_approx(velocity.x):
		p_data.facing_direction = sign(velocity.x)

func _emit_healing_charges_changed_event():
	var ev = PlayerHealingChargesChangedEvent.new()
	ev.current_charges = p_data.healing_charges
	EventBus.emit(EventCatalog.PLAYER_HEALING_CHARGES_CHANGED, ev)
	healing_charges_changed.emit(p_data.healing_charges)

func _check_for_contact_damage():
	if p_data.is_pogo_attack:
		return

	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i)
		if col:
			var collider = col.get_collider()
			if collider.is_in_group("enemy") or collider.is_in_group("hazard"):
				var damage_result = health_component.take_damage(1, collider)
				if damage_result["was_damaged"]:
					velocity = damage_result["knockback_velocity"]
					change_state(State.HURT)
				break

func _on_damage_dealt():
	if p_data.healing_charges >= CombatDB.config.player_max_healing_charges: return
	p_data.determination_counter += 1
	if p_data.determination_counter >= CombatDB.config.player_determination_per_charge:
		p_data.determination_counter = 0; p_data.healing_charges += 1
		_emit_healing_charges_changed_event()

func _cancel_heal():
	if healing_timer.is_stopped(): return
	healing_timer.stop()

func _on_hitbox_body_entered(body):
	# --- DEBUG PRINT ---
	print("[DEBUG] Hitbox collided with: ", body.name, " | In Groups: ", body.get_groups())
	if p_data.is_pogo_attack:
		combat_component.trigger_pogo(body)
	elif body.is_in_group("enemy"):
		var enemy_health_comp = body.get_node_or_null("HealthComponent")
		if enemy_health_comp:
			enemy_health_comp.take_damage(1, self)
			_on_damage_dealt()

func _on_hitbox_area_entered(area):
	if area.is_in_group("enemy_projectile"):
		if p_data.is_pogo_attack:
			combat_component.trigger_pogo(area)
			ObjectPool.return_instance(area)
		else:
			ObjectPool.return_instance(area)

func _on_hurtbox_area_entered(area):
	if area.is_in_group("enemy_projectile"):
		var damage_result = health_component.take_damage(1, area)
		if damage_result["was_damaged"]:
			velocity = damage_result["knockback_velocity"]
			change_state(State.HURT)
		ObjectPool.return_instance(area)

func _on_healing_timer_timeout():
	if states.find_key(current_state) == State.HEAL:
		p_data.health += 1
		p_data.healing_charges -= 1
		health_component.health_changed.emit(p_data.health, p_data.max_health)
		_emit_healing_charges_changed_event()
		change_state(State.MOVE)

func _on_health_component_health_changed(current, max_val):
	var ev = PlayerHealthChangedEvent.new()
	ev.current_health = current
	ev.max_health = max_val
	EventBus.emit(EventCatalog.PLAYER_HEALTH_CHANGED, ev)
	health_changed.emit(current, max_val)

func _on_health_component_died():
	died.emit()
