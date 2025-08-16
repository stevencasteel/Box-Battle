# src/entities/boss/base_boss.gd
@tool
## The base class for all boss enemies.
##
## Orchestrates the boss's components (Health, StateMachine, Armor) and manages
## phase transitions and attack pattern selection. It is designed to be data-driven,
## with attack patterns configured directly in the Inspector.
class_name BaseBoss
extends CharacterBody2D

# --- Constants ---
const Validator = preload("res://src/core/util/scene_validator.gd")

# --- Enums ---
enum State { IDLE, ATTACK, COOLDOWN, PATROL, LUNGE }

# --- Editor Configuration ---
@export_group("Phase Configuration")
@export_range(0.0, 1.0, 0.01) var phase_2_threshold: float = 0.7
@export_range(0.0, 1.0, 0.01) var phase_3_threshold: float = 0.4

@export_group("Attack Patterns")
@export var phase_1_patterns: Array[AttackPattern] = []
@export var phase_2_patterns: Array[AttackPattern] = []
@export var phase_3_patterns: Array[AttackPattern] = []

# --- Node References ---
@onready var visual_sprite: ColorRect = $ColorRect
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var patrol_timer: Timer = $PatrolTimer
@onready var health_component: HealthComponent = $HealthComponent
@onready var state_machine: BaseStateMachine = $StateMachine
@onready var armor_component: ArmorComponent = $ArmorComponent

# --- Public Member Variables ---
## The array of [AttackPattern] resources for the current combat phase.
var current_attack_patterns: Array[AttackPattern] = []
## The number of health phases remaining (e.g., 3, 2, or 1).
var phases_remaining: int = 3

# --- Private Member Variables ---
var _b_data: BossStateData
var _player: CharacterBody2D = null
var _active_attack_tween: Tween
var _is_dead: bool = false

# --- Godot Lifecycle Methods ---

func _get_configuration_warnings() -> PackedStringArray:
	return Validator.validate_boss_scene(self)

func _ready() -> void:
	if Engine.is_editor_hint(): return

	_initialize_data()
	_initialize_components()
	_initialize_state_machine()
	_connect_signals()

	_player = get_tree().get_first_node_in_group(Identifiers.Groups.PLAYER)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid(state_machine): state_machine.teardown()
		if is_instance_valid(health_component): health_component.teardown()
		_b_data = null

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return

	if not is_on_floor():
		velocity.y += _b_data.config.gravity * delta

	move_and_slide()
	if state_machine.current_state == state_machine.states[State.PATROL] and is_on_wall():
		_b_data.facing_direction *= -1.0

# --- Public Methods ---

## Returns the health percentage thresholds for phase transitions.
func get_health_thresholds() -> Array[float]:
	return [phase_2_threshold, phase_3_threshold]

## Initiates the boss death sequence.
func die() -> void:
	if _is_dead: return
	_is_dead = true
	if is_instance_valid(_active_attack_tween): _active_attack_tween.kill()
	set_physics_process(false)
	hide()
	EventBus.emit(EventCatalog.BOSS_DIED, {"boss_node": self})

## Fires a volley of multiple shots at the player with a delay.
func fire_volley(shot_count: int) -> void:
	if is_instance_valid(_active_attack_tween): _active_attack_tween.kill()
	_active_attack_tween = get_tree().create_tween()
	for i in range(shot_count):
		_active_attack_tween.tween_callback(fire_shot_at_player)
		if i < shot_count - 1: _active_attack_tween.tween_interval(0.2)

## Fires a single projectile towards the player's current position.
func fire_shot_at_player() -> void:
	if _is_dead or not is_instance_valid(_player): return
	var shot = ObjectPool.get_instance(Identifiers.Pools.BOSS_SHOTS)
	if not shot: return

	_update_player_tracking()
	shot.direction = (_player.global_position - global_position).normalized()
	shot.global_position = global_position
	shot.activate()

# --- Private Methods ---

func _initialize_data() -> void:
	add_to_group(Identifiers.Groups.ENEMY)
	visual_sprite.color = Palette.COLOR_BOSS_PRIMARY
	current_attack_patterns = phase_1_patterns
	_b_data = BossStateData.new()
	_b_data.config = CombatDB.config

func _initialize_components() -> void:
	health_component.setup(self, { "data_resource": _b_data, "config": _b_data.config })
	armor_component.setup(self)

func _initialize_state_machine() -> void:
	var states = {
		State.IDLE: BossStateIdle.new(self, state_machine, _b_data),
		State.ATTACK: BossStateAttack.new(self, state_machine, _b_data),
		State.COOLDOWN: BossStateCooldown.new(self, state_machine, _b_data),
		State.PATROL: BossStatePatrol.new(self, state_machine, _b_data),
		State.LUNGE: BossStateLunge.new(self, state_machine, _b_data),
	}
	state_machine.setup(self, { "states": states, "initial_state_key": State.COOLDOWN })

func _connect_signals() -> void:
	health_component.health_changed.connect(_on_health_component_health_changed)
	health_component.died.connect(_on_health_component_died)
	health_component.health_threshold_reached.connect(_on_health_threshold_reached)

## Updates the boss's facing direction based on the player's position.
func _update_player_tracking() -> void:
	if is_instance_valid(_player):
		var dir_to_player = _player.global_position.x - global_position.x
		if not is_zero_approx(dir_to_player):
			_b_data.facing_direction = sign(dir_to_player)
	self.scale.x = _b_data.facing_direction

# --- Signal Handlers ---

func _on_health_threshold_reached(health_percentage: float) -> void:
	var new_phases_remaining = phases_remaining
	if health_percentage <= phase_3_threshold and phases_remaining > 1:
		new_phases_remaining = 1
	elif health_percentage <= phase_2_threshold and phases_remaining > 2:
		new_phases_remaining = 2

	if new_phases_remaining != phases_remaining:
		phases_remaining = new_phases_remaining
		match phases_remaining:
			2: current_attack_patterns = phase_2_patterns
			1: current_attack_patterns = phase_3_patterns
		EventBus.emit(EventCatalog.BOSS_PHASE_CHANGED, {"phases_remaining": phases_remaining})

func _on_cooldown_timer_timeout() -> void:
	if state_machine.current_state == state_machine.states[State.COOLDOWN]:
		state_machine.change_state(State.PATROL)

func _on_patrol_timer_timeout() -> void:
	if state_machine.current_state == state_machine.states[State.PATROL]:
		state_machine.change_state(State.IDLE)

func _on_health_component_health_changed(current: int, max_val: int) -> void:
	var ev = BossHealthChangedEvent.new()
	ev.current_health = current
	ev.max_health = max_val
	EventBus.emit(EventCatalog.BOSS_HEALTH_CHANGED, ev)

func _on_health_component_died() -> void:
	die()
