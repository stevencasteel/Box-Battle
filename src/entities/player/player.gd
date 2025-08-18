# src/entities/player/player.gd
@tool
class_name Player
extends CharacterBody2D

# --- Signals ---
signal health_changed(current_health, max_health)
signal died

# --- Enums ---
enum State {MOVE, JUMP, FALL, DASH, WALL_SLIDE, ATTACK, HURT, HEAL}

# --- Constants ---
const ACTION_ALLOWED_STATES = [State.MOVE, State.FALL, State.JUMP, State.WALL_SLIDE]
const CLOSE_RANGE_THRESHOLD = 75.0
const CombatUtilsScript = preload(AssetPaths.SCRIPT_COMBAT_UTILS)

# --- Editor Properties ---
@export var damage_shake_effect: ScreenShakeEffect

# --- Node References ---
@onready var visual_sprite: ColorRect = $ColorRect
@onready var hurtbox: Area2D = $Hurtbox
@onready var healing_timer: Timer = $HealingTimer
@onready var melee_hitbox: Area2D = $MeleeHitbox
@onready var pogo_hitbox: Area2D = $PogoHitbox
@onready var melee_hitbox_shape: CollisionShape2D = $MeleeHitbox/CollisionShape2D
@onready var pogo_hitbox_shape: CollisionShape2D = $PogoHitbox/CollisionShape2D

# --- Component References ---
@onready var health_component: HealthComponent = $HealthComponent
@onready var combat_component: CombatComponent = $CombatComponent
@onready var input_component: InputComponent = $InputComponent
@onready var state_machine: BaseStateMachine = $StateMachine
@onready var physics_component: PlayerPhysicsComponent = $PlayerPhysicsComponent
@onready var ability_component: PlayerAbilityComponent = $PlayerAbilityComponent
@onready var resource_component: PlayerResourceComponent = $PlayerResourceComponent

# --- Data ---
var entity_data: PlayerStateData

# --- Godot Lifecycle Methods ---

func _ready() -> void:
	add_to_group(Identifiers.Groups.PLAYER)
	_initialize_data()
	_initialize_components()
	_initialize_state_machine()
	_connect_signals()
	visual_sprite.color = Palette.COLOR_PLAYER
	resource_component.on_damage_dealt()
	entity_data.determination_counter = 0

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		teardown()

func _physics_process(delta: float) -> void:
	_update_timers(delta)

# --- Public Methods ---

func teardown() -> void:
	if is_instance_valid(health_component):
		if health_component.health_changed.is_connected(_on_health_component_health_changed):
			health_component.health_changed.disconnect(_on_health_component_health_changed)
		if health_component.died.is_connected(_on_health_component_died):
			health_component.died.disconnect(_on_health_component_died)
		if health_component.took_damage.is_connected(_on_health_component_took_damage):
			health_component.took_damage.disconnect(_on_health_component_took_damage)
	if is_instance_valid(combat_component):
		if combat_component.damage_dealt.is_connected(resource_component.on_damage_dealt):
			combat_component.damage_dealt.disconnect(resource_component.on_damage_dealt)
		if combat_component.pogo_bounce_requested.is_connected(_on_pogo_bounce_requested):
			combat_component.pogo_bounce_requested.disconnect(_on_pogo_bounce_requested)
	if is_instance_valid(state_machine): state_machine.teardown()
	if is_instance_valid(health_component): health_component.teardown()
	if is_instance_valid(combat_component): combat_component.teardown()
	if is_instance_valid(input_component): input_component.teardown()
	if is_instance_valid(physics_component): physics_component.teardown()
	if is_instance_valid(ability_component): ability_component.teardown()
	if is_instance_valid(resource_component): resource_component.teardown()
	entity_data = null

# --- Private Methods ---

func _initialize_data() -> void:
	entity_data = PlayerStateData.new()
	entity_data.config = CombatDB.config

func _initialize_components() -> void:
	health_component.setup(self, { "data_resource": entity_data, "config": entity_data.config })
	combat_component.setup(self, { "data_resource": entity_data })
	input_component.setup(self, { "data_resource": entity_data, "state_machine": state_machine, "config": entity_data.config })
	physics_component.setup(self, { "data_resource": entity_data, "health_component": health_component })
	ability_component.setup(self, { "data_resource": entity_data, "state_machine": state_machine, "input_component": input_component })
	resource_component.setup(self, { "data_resource": entity_data })

func _initialize_state_machine() -> void:
	var states = {
		State.MOVE: load("res://src/entities/player/states/state_move.gd").new(self, state_machine, entity_data),
		State.FALL: load("res://src/entities/player/states/state_fall.gd").new(self, state_machine, entity_data),
		State.JUMP: load("res://src/entities/player/states/state_jump.gd").new(self, state_machine, entity_data),
		State.DASH: load("res://src/entities/player/states/state_dash.gd").new(self, state_machine, entity_data),
		State.WALL_SLIDE: load("res://src/entities/player/states/state_wall_slide.gd").new(self, state_machine, entity_data),
		State.ATTACK: load("res://src/entities/player/states/state_attack.gd").new(self, state_machine, entity_data),
		State.HURT: load("res://src/entities/player/states/state_hurt.gd").new(self, state_machine, entity_data),
		State.HEAL: load("res://src/entities/player/states/state_heal.gd").new(self, state_machine, entity_data),
	}
	state_machine.setup(self, { "states": states, "initial_state_key": State.FALL })

func _connect_signals() -> void:
	melee_hitbox.body_entered.connect(_on_melee_hitbox_body_entered)
	pogo_hitbox.body_entered.connect(_on_pogo_hitbox_body_entered)
	melee_hitbox.area_entered.connect(_on_hitbox_area_entered)
	pogo_hitbox.area_entered.connect(_on_hitbox_area_entered)
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	health_component.health_changed.connect(_on_health_component_health_changed)
	health_component.died.connect(_on_health_component_died)
	health_component.took_damage.connect(_on_health_component_took_damage)
	combat_component.damage_dealt.connect(resource_component.on_damage_dealt)
	combat_component.pogo_bounce_requested.connect(_on_pogo_bounce_requested)

func _update_timers(delta: float) -> void:
	entity_data.coyote_timer = max(0.0, entity_data.coyote_timer - delta)
	entity_data.wall_coyote_timer = max(0.0, entity_data.wall_coyote_timer - delta)
	entity_data.dash_cooldown_timer = max(0.0, entity_data.dash_cooldown_timer - delta)
	entity_data.dash_duration_timer = max(0.0, entity_data.dash_duration_timer - delta)
	entity_data.attack_duration_timer = max(0.0, entity_data.attack_duration_timer - delta)
	entity_data.attack_cooldown_timer = max(0.0, entity_data.attack_cooldown_timer - delta)
	entity_data.knockback_timer = max(0.0, entity_data.knockback_timer - delta)
	entity_data.pogo_fall_prevention_timer = max(0.0, entity_data.pogo_fall_prevention_timer - delta)
	if entity_data.is_charging and input_component.buffer.get("attack_pressed"):
		entity_data.charge_timer += delta

# --- Signal Handlers ---
func _on_melee_hitbox_body_entered(body: Node) -> void:
	var target_id = body.get_instance_id()
	if entity_data.hit_targets_this_swing.has(target_id): return
	entity_data.hit_targets_this_swing[target_id] = true
	var damageable = CombatUtilsScript.find_damageable(body)
	if is_instance_valid(damageable):
		var damage_info = DamageInfo.new()
		damage_info.source_node = self
		var distance = self.global_position.distance_to(body.global_position)
		var is_close_range = distance <= CLOSE_RANGE_THRESHOLD
		damage_info.amount = 5 if is_close_range else 1
		var damage_result = damageable.apply_damage(damage_info)
		if damage_result.was_damaged:
			resource_component.on_damage_dealt()
func _on_pogo_hitbox_body_entered(body: Node) -> void:
	combat_component.trigger_pogo(body)
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group(Identifiers.Groups.ENEMY_PROJECTILE):
		if entity_data.is_pogo_attack:
			combat_component.trigger_pogo(area)
		else:
			ObjectPool.return_instance(area)
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if health_component.is_invincible(): return
	if area.is_in_group(Identifiers.Groups.ENEMY_PROJECTILE):
		var damage_info = DamageInfo.new()
		damage_info.amount = 1
		damage_info.source_node = area
		var damage_result = health_component.apply_damage(damage_info)
		if damage_result.was_damaged:
			self.velocity = damage_result.knockback_velocity
			state_machine.change_state(State.HURT)
		ObjectPool.return_instance(area)
func _on_healing_timer_timeout() -> void:
	if state_machine.current_state == state_machine.states[State.HEAL]:
		entity_data.health += 1; entity_data.healing_charges -= 1
		_on_health_component_health_changed(entity_data.health, entity_data.max_health)
		resource_component.on_damage_dealt()
		state_machine.change_state(State.MOVE)
func _on_health_component_health_changed(current: int, max_val: int) -> void:
	var ev = PlayerHealthChangedEvent.new()
	ev.current_health = current
	ev.max_health = max_val
	EventBus.emit(EventCatalog.PLAYER_HEALTH_CHANGED, ev)
	health_changed.emit(current, max_val)
func _on_health_component_died() -> void:
	died.emit()
func _on_health_component_took_damage(_damage_info: DamageInfo, _damage_result: DamageResult) -> void:
	if is_instance_valid(damage_shake_effect):
		FXManager.request_screen_shake(damage_shake_effect)
func _on_pogo_bounce_requested() -> void:
	velocity.y = -entity_data.config.player_pogo_force
	position.y -= 1
	entity_data.can_dash = true
	entity_data.air_jumps_left = entity_data.config.player_max_air_jumps
	state_machine.change_state(State.FALL)
func _cancel_heal() -> void:
	if healing_timer.is_stopped(): return
	healing_timer.stop()