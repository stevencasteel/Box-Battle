# src/entities/player/player.gd
# REFACTORED: The _ready function is now broken into smaller helper methods
# to improve readability and adhere to the Single Responsibility Principle.
extends CharacterBody2D

const CombatUtilsScript = preload(AssetPaths.SCRIPT_COMBAT_UTILS)

# --- Signals ---
signal health_changed(current_health, max_health)
signal healing_charges_changed(current_charges)
signal died

# --- State Enum ---
enum State {MOVE, JUMP, FALL, DASH, WALL_SLIDE, ATTACK, HURT, HEAL}

# --- Node References ---
@onready var visual_sprite: ColorRect = $ColorRect
@onready var hurtbox: Area2D = $Hurtbox
@onready var healing_timer: Timer = $HealingTimer
@onready var health_component: HealthComponent = $HealthComponent
@onready var combat_component: CombatComponent = $CombatComponent
@onready var input_component: InputComponent = $InputComponent
@onready var state_machine: BaseStateMachine = $StateMachine

@onready var melee_hitbox: Area2D = $MeleeHitbox
@onready var pogo_hitbox: Area2D = $PogoHitbox
@onready var melee_hitbox_shape: CollisionShape2D = $MeleeHitbox/CollisionShape2D
@onready var pogo_hitbox_shape: CollisionShape2D = $PogoHitbox/CollisionShape2D

# --- Constants ---
const CLOSE_RANGE_THRESHOLD = 75.0

# --- Data ---
var p_data: PlayerStateData
const ACTION_ALLOWED_STATES = [State.MOVE, State.FALL, State.JUMP, State.WALL_SLIDE]

# --- Engine Functions ---

func _ready():
	add_to_group(Identifiers.Groups.PLAYER)
	
	_initialize_data()
	_initialize_components()
	_initialize_state_machine()
	_connect_signals()

	visual_sprite.color = Palette.COLOR_PLAYER
	_emit_healing_charges_changed_event()

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid(state_machine): state_machine.teardown()
		if is_instance_valid(health_component): health_component.teardown()
		if is_instance_valid(combat_component): combat_component.teardown()
		if is_instance_valid(input_component): input_component.teardown()
		p_data = null

func _physics_process(delta):
	_update_timers(delta)
	move_and_slide()
	_check_for_contact_damage()
	if is_on_wall() and not is_on_floor():
		p_data.wall_coyote_timer = p_data.config.player_wall_coyote_time
		p_data.last_wall_normal = get_wall_normal()

# --- Private Helper Functions ---

func _initialize_data():
	p_data = PlayerStateData.new()
	p_data.config = CombatDB.config

func _initialize_components():
	health_component.setup(self, { "data_resource": p_data, "config": p_data.config })
	combat_component.setup(self, { "data_resource": p_data })
	input_component.setup(self, { "data_resource": p_data, "state_machine": state_machine, "combat_component": combat_component, "config": p_data.config })

func _initialize_state_machine():
	var states = {
		State.MOVE: load("res://src/entities/player/states/state_move.gd").new(self, state_machine, p_data),
		State.FALL: load("res://src/entities/player/states/state_fall.gd").new(self, state_machine, p_data),
		State.JUMP: load("res://src/entities/player/states/state_jump.gd").new(self, state_machine, p_data),
		State.DASH: load("res://src/entities/player/states/state_dash.gd").new(self, state_machine, p_data),
		State.WALL_SLIDE: load("res://src/entities/player/states/state_wall_slide.gd").new(self, state_machine, p_data),
		State.ATTACK: load("res://src/entities/player/states/state_attack.gd").new(self, state_machine, p_data),
		State.HURT: load("res://src/entities/player/states/state_hurt.gd").new(self, state_machine, p_data),
		State.HEAL: load("res://src/entities/player/states/state_heal.gd").new(self, state_machine, p_data),
	}
	state_machine.setup(self, { "states": states, "initial_state_key": State.FALL })

func _connect_signals():
	melee_hitbox.body_entered.connect(_on_melee_hitbox_body_entered)
	pogo_hitbox.body_entered.connect(_on_pogo_hitbox_body_entered)
	melee_hitbox.area_entered.connect(_on_hitbox_area_entered)
	pogo_hitbox.area_entered.connect(_on_hitbox_area_entered)
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	health_component.health_changed.connect(_on_health_component_health_changed)
	health_component.died.connect(_on_health_component_died)
	combat_component.damage_dealt.connect(_on_damage_dealt)
	combat_component.pogo_bounce_requested.connect(_on_pogo_bounce_requested)

func apply_horizontal_movement():
	velocity.x = Input.get_axis("ui_left", "ui_right") * p_data.config.player_speed
	if not is_zero_approx(velocity.x):
		p_data.facing_direction = sign(velocity.x)

func _cancel_heal():
	if healing_timer.is_stopped(): return
	healing_timer.stop()

func _update_timers(delta):
	p_data.coyote_timer = max(0.0, p_data.coyote_timer - delta)
	p_data.jump_buffer_timer = max(0.0, p_data.jump_buffer_timer - delta)
	p_data.dash_cooldown_timer = max(0.0, p_data.dash_cooldown_timer - delta)
	p_data.dash_duration_timer = max(0.0, p_data.dash_duration_timer - delta)
	p_data.attack_duration_timer = max(0.0, p_data.attack_duration_timer - delta)
	p_data.attack_cooldown_timer = max(0.0, p_data.attack_cooldown_timer - delta)
	p_data.knockback_timer = max(0.0, p_data.knockback_timer - delta)
	p_data.wall_coyote_timer = max(0.0, p_data.wall_coyote_timer - delta)
	p_data.pogo_fall_prevention_timer = max(0.0, p_data.pogo_fall_prevention_timer - delta)
	if p_data.is_charging and Input.is_action_pressed("ui_attack"):
		p_data.charge_timer += delta

func _emit_healing_charges_changed_event():
	var ev = PlayerHealingChargesChangedEvent.new()
	ev.current_charges = p_data.healing_charges
	EventBus.emit(EventCatalog.PLAYER_HEALING_CHARGES_CHANGED, ev)
	healing_charges_changed.emit(p_data.healing_charges)

func _check_for_contact_damage():
	if p_data.is_invincible: return
	for i in range(get_slide_collision_count()):
		var col = get_slide_collision(i)
		if not col: continue
		
		var collider = col.get_collider()
		if not (is_instance_valid(collider) and (collider.is_in_group(Identifiers.Groups.ENEMY) or collider.is_in_group(Identifiers.Groups.HAZARD))): continue
		
		var damage_info = DamageInfo.new()
		damage_info.amount = 1
		damage_info.source_node = collider
		var damage_result = health_component.apply_damage(damage_info)
		
		if damage_result.was_damaged:
			self.velocity = damage_result.knockback_velocity
			state_machine.change_state(State.HURT)
		break

func _on_damage_dealt():
	if p_data.healing_charges >= p_data.config.player_max_healing_charges: return
	p_data.determination_counter += 1
	if p_data.determination_counter >= p_data.config.player_determination_per_charge:
		p_data.determination_counter = 0; p_data.healing_charges += 1
		_emit_healing_charges_changed_event()

# --- Signal Handlers (Connected in Editor or _ready) ---
func _on_melee_hitbox_body_entered(body: Node) -> void:
	var target_id = body.get_instance_id()
	if p_data.hit_targets_this_swing.has(target_id): return
	p_data.hit_targets_this_swing[target_id] = true
	
	var damageable = CombatUtilsScript.find_damageable(body)
	if is_instance_valid(damageable):
		var damage_info = DamageInfo.new()
		damage_info.source_node = self
		var distance = self.global_position.distance_to(body.global_position)
		damage_info.amount = 5 if distance <= CLOSE_RANGE_THRESHOLD else 1
			
		var damage_result = damageable.apply_damage(damage_info)
		if damage_result.was_damaged:
			_on_damage_dealt()

func _on_pogo_hitbox_body_entered(body: Node) -> void:
	combat_component.trigger_pogo(body)

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group(Identifiers.Groups.ENEMY_PROJECTILE):
		if p_data.is_pogo_attack:
			combat_component.trigger_pogo(area)
		else:
			ObjectPool.return_instance(area)

func _on_hurtbox_area_entered(area: Area2D) -> void:
	if p_data.is_invincible or p_data.is_dash_invincible:
		if area.is_in_group(Identifiers.Groups.ENEMY_PROJECTILE): ObjectPool.return_instance(area)
		return
	
	if area.is_in_group(Identifiers.Groups.ENEMY_PROJECTILE):
		var damage_info = DamageInfo.new()
		damage_info.amount = 1
		damage_info.source_node = area
		var damage_result = health_component.apply_damage(damage_info)
		
		if damage_result.was_damaged:
			self.velocity = damage_result.knockback_velocity
			state_machine.change_state(State.HURT)
		
		ObjectPool.return_instance(area)

func _on_healing_timer_timeout():
	if state_machine.current_state == state_machine.states[State.HEAL]:
		p_data.health += 1; p_data.healing_charges -= 1
		_on_health_component_health_changed(p_data.health, p_data.max_health)
		_emit_healing_charges_changed_event()
		state_machine.change_state(State.MOVE)

func _on_health_component_health_changed(current: int, max_val: int) -> void:
	var ev = PlayerHealthChangedEvent.new()
	ev.current_health = current
	ev.max_health = max_val
	EventBus.emit(EventCatalog.PLAYER_HEALTH_CHANGED, ev)
	health_changed.emit(current, max_val)

func _on_health_component_died():
	died.emit()

func _on_pogo_bounce_requested():
	velocity.y = -p_data.config.player_pogo_force
	position.y -= 1
	p_data.can_dash = true
	p_data.air_jumps_left = p_data.config.player_max_air_jumps
	state_machine.change_state(State.FALL)
