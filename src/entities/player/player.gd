# src/entities/player/player.gd
@tool
class_name Player
extends BaseEntity

# --- Signals ---
signal health_changed(current_health, max_health)
signal died

# --- Enums ---
enum State {MOVE, JUMP, FALL, DASH, WALL_SLIDE, ATTACK, HURT, HEAL, POGO}

# --- Constants ---
const ACTION_ALLOWED_STATES = [State.MOVE, State.FALL, State.JUMP, State.WALL_SLIDE]
const CombatUtilsScript = preload(AssetPaths.SCRIPT_COMBAT_UTILS)
const COMBAT_CONFIG = preload("res://src/data/combat_config.tres")
const HIT_FLASH_EFFECT = preload("res://src/data/effects/entity_hit_flash_effect.tres")

# --- Editor Properties ---
@export_group("Juice & Feedback")
@export var damage_shake_effect: ScreenShakeEffect
@export var hit_spark_effect: VFXEffect
@export_group("State Scripts")
@export var state_move_script: Script
@export var state_jump_script: Script
@export var state_fall_script: Script
@export var state_dash_script: Script
@export var state_wall_slide_script: Script
@export var state_attack_script: Script
@export var state_hurt_script: Script
@export var state_heal_script: Script
@export var state_pogo_script: Script

# --- Node References ---
@onready var visual_sprite: ColorRect = $ColorRect
@onready var hurtbox: Area2D = $Hurtbox
@onready var healing_timer: Timer = $HealingTimer
@onready var melee_hitbox: Area2D = $MeleeHitbox
@onready var pogo_hitbox: Area2D = $PogoHitbox

# --- Data ---
var entity_data: PlayerStateData

# --- Private Member Variables ---
var _object_pool: ObjectPool

# --- Godot Lifecycle Methods ---

func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint(): return

	add_to_group(Identifiers.Groups.PLAYER)
	_initialize_and_setup_components()
	_connect_signals()

	visual_sprite.color = Palette.COLOR_PLAYER
	# TODO: This is a temporary fix to initialize the UI. Should be event driven.
	resource_component.on_damage_dealt()
	entity_data.determination_counter = 0

func _physics_process(delta: float) -> void:
	_update_timers(delta)

# --- Public Methods ---

func teardown() -> void:
	# Disconnect signals that THIS script is listening to.
	if is_instance_valid(health_component):
		if health_component.health_changed.is_connected(_on_health_component_health_changed):
			health_component.health_changed.disconnect(_on_health_component_health_changed)
		if health_component.died.is_connected(_on_health_component_died):
			health_component.died.disconnect(_on_health_component_died)
	if is_instance_valid(combat_component):
		if combat_component.damage_dealt.is_connected(resource_component.on_damage_dealt):
			combat_component.damage_dealt.disconnect(resource_component.on_damage_dealt)
		if combat_component.pogo_bounce_requested.is_connected(_on_pogo_bounce_requested):
			combat_component.pogo_bounce_requested.disconnect(_on_pogo_bounce_requested)
	if is_instance_valid(state_machine):
		if state_machine.action_requested.is_connected(_on_state_machine_action_requested):
			state_machine.action_requested.disconnect(_on_state_machine_action_requested)

	super.teardown()
	entity_data = null

# --- Private Methods ---

func _enable_melee_hitbox(is_enabled: bool, is_up_attack: bool = false) -> void:
	var shape_node: CollisionShape2D = melee_hitbox.get_node("CollisionShape2D")
	if is_enabled:
		if is_up_attack:
			shape_node.shape = entity_data.config.player_upward_attack_shape
			shape_node.position = Vector2(0, -40)
		else:
			shape_node.shape = entity_data.config.player_forward_attack_shape
			shape_node.position = Vector2(entity_data.facing_direction * 60, 0)
	shape_node.disabled = not is_enabled

func _enable_pogo_hitbox(is_enabled: bool) -> void:
	var shape_node: CollisionShape2D = pogo_hitbox.get_node("CollisionShape2D")
	shape_node.position = Vector2(0, 40)
	shape_node.disabled = not is_enabled

func _initialize_and_setup_components() -> void:
	entity_data = PlayerStateData.new()
	entity_data.config = COMBAT_CONFIG
	_object_pool = ObjectPool
	
	var shared_deps := {
		"data_resource": entity_data,
		"config": entity_data.config,
		"health_component": health_component,
		"object_pool": _object_pool,
		"event_bus": EventBus
	}
	
	var states = {
		State.MOVE: state_move_script.new(self, state_machine, entity_data),
		State.FALL: state_fall_script.new(self, state_machine, entity_data),
		State.JUMP: state_jump_script.new(self, state_machine, entity_data),
		State.DASH: state_dash_script.new(self, state_machine, entity_data),
		State.WALL_SLIDE: state_wall_slide_script.new(self, state_machine, entity_data),
		State.ATTACK: state_attack_script.new(self, state_machine, entity_data),
		State.HURT: state_hurt_script.new(self, state_machine, entity_data),
		State.HEAL: state_heal_script.new(self, state_machine, entity_data),
		State.POGO: state_pogo_script.new(self, state_machine, entity_data),
	}
	
	var per_component_deps := {
		state_machine: {"states": states, "initial_state_key": State.FALL},
		input_component: {"state_machine": state_machine},
		ability_component: {"state_machine": state_machine, "input_component": input_component},
		fx_component: {"visual_node": visual_sprite, "health_component": health_component, "hit_effect": HIT_FLASH_EFFECT}
	}
	
	setup_components(shared_deps, per_component_deps)


func _connect_signals() -> void:
	melee_hitbox.body_entered.connect(_on_melee_hitbox_body_entered)
	pogo_hitbox.body_entered.connect(_on_pogo_hitbox_body_entered)
	melee_hitbox.area_entered.connect(_on_hitbox_area_entered)
	pogo_hitbox.area_entered.connect(_on_hitbox_area_entered)
	hurtbox.area_entered.connect(_on_hurtbox_area_entered)
	health_component.health_changed.connect(_on_health_component_health_changed)
	health_component.died.connect(_on_health_component_died)
	combat_component.damage_dealt.connect(resource_component.on_damage_dealt)
	combat_component.pogo_bounce_requested.connect(_on_pogo_bounce_requested)
	state_machine.action_requested.connect(_on_state_machine_action_requested)

func _update_timers(delta: float) -> void:
	if not is_instance_valid(entity_data): return

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

func _on_state_machine_action_requested(command: Callable) -> void:
	if command.is_valid():
		command.call()

func _on_melee_hitbox_body_entered(body: Node) -> void:
	var target_id = body.get_instance_id()
	if entity_data.hit_targets_this_swing.has(target_id): return
	entity_data.hit_targets_this_swing[target_id] = true
	var damageable = CombatUtilsScript.find_damageable(body)
	if is_instance_valid(damageable):
		var damage_info = DamageInfo.new()
		damage_info.source_node = self
		var distance = self.global_position.distance_to(body.global_position)
		var is_close_range = distance <= entity_data.config.player_close_range_threshold
		damage_info.amount = 5 if is_close_range else 1
		damage_info.impact_position = body.global_position
		damage_info.impact_normal = (body.global_position - global_position).normalized()
		var damage_result = damageable.apply_damage(damage_info)
		if damage_result.was_damaged:
			resource_component.on_damage_dealt()
			if is_close_range:
				FXManager.request_hit_stop(entity_data.config.player_melee_close_range_hit_stop_duration)
func _on_pogo_hitbox_body_entered(body: Node) -> void:
	combat_component.trigger_pogo(body)
func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.is_in_group(Identifiers.Groups.ENEMY_PROJECTILE):
		if entity_data.is_pogo_attack:
			combat_component.trigger_pogo(area)
		else:
			_object_pool.return_instance.call_deferred(area)
func _on_hurtbox_area_entered(area: Area2D) -> void:
	if health_component.is_invincible(): return
	if area.is_in_group(Identifiers.Groups.ENEMY_PROJECTILE):
		var damage_info = DamageInfo.new()
		damage_info.amount = 1
		damage_info.source_node = area
		damage_info.impact_position = global_position
		damage_info.impact_normal = (global_position - area.global_position).normalized()
		var damage_result = health_component.apply_damage(damage_info)
		
		if not is_instance_valid(entity_data): return
		
		if damage_result.was_damaged and entity_data.health > 0:
			self.velocity = damage_result.knockback_velocity
			state_machine.change_state(State.HURT)
		_object_pool.return_instance.call_deferred(area)
func _on_healing_timer_timeout() -> void:
	if state_machine.current_state == state_machine.states[State.HEAL]:
		entity_data.health += 1
		resource_component.consume_healing_charge()
		_on_health_component_health_changed(entity_data.health, entity_data.max_health)
		state_machine.change_state(State.MOVE)
func _on_health_component_health_changed(current: int, max_val: int) -> void:
	var ev = PlayerHealthChangedEvent.new()
	ev.current_health = current
	ev.max_health = max_val
	EventBus.emit(EventCatalog.PLAYER_HEALTH_CHANGED, ev)
	health_changed.emit(current, max_val)
func _on_health_component_died() -> void:
	died.emit()
func _on_pogo_bounce_requested() -> void:
	velocity.y = -entity_data.config.player_pogo_force
	position.y -= 1
	entity_data.can_dash = true
	entity_data.air_jumps_left = entity_data.config.player_max_air_jumps
	state_machine.change_state(State.FALL)
func _cancel_heal() -> void:
	if healing_timer.is_stopped(): return
	healing_timer.stop()
