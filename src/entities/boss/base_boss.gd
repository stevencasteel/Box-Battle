# src/entities/boss/base_boss.gd
@tool
class_name BaseBoss
extends BaseEntity

# --- Constants ---
const COMBAT_CONFIG = preload("res://src/data/combat_config.tres")

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
@export_group("Juice & Feedback")
@export var intro_shake_effect: ScreenShakeEffect
@export var phase_change_shake_effect: ScreenShakeEffect
@export var death_shake_effect: ScreenShakeEffect
@export var hit_spark_effect: VFXEffect
@export_group("State Scripts")
@export var state_idle_script: Script
@export var state_attack_script: Script
@export var state_cooldown_script: Script
@export var state_patrol_script: Script
@export var state_lunge_script: Script

# --- Node References ---
@onready var visual_sprite: ColorRect = $ColorRect
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var patrol_timer: Timer = $PatrolTimer

# --- Public Member Variables ---
var current_attack_patterns: Array[AttackPattern] = []
var phases_remaining: int = 3
var entity_data: BossStateData

# --- Private Member Variables ---
var _player: CharacterBody2D = null
var _active_attack_tween: Tween
var _is_dead: bool = false

# --- Godot Lifecycle Methods ---

func _get_configuration_warnings() -> PackedStringArray:
	var warnings = PackedStringArray()
	if not archetype:
		warnings.append("This node requires an EntityArchetype resource.")
		return warnings
	if phase_1_patterns.is_empty():
		warnings.append("Phase 1 has no attack patterns assigned.")
	return warnings

func _ready() -> void:
	super._ready()
	if Engine.is_editor_hint(): return
	
	_initialize_data()
	_initialize_and_setup_components()
	_connect_signals()
	_player = get_tree().get_first_node_in_group(Identifiers.Groups.PLAYER)
	
	if is_instance_valid(intro_shake_effect):
		FXManager.request_screen_shake(intro_shake_effect)

func _notification(what: int) -> void:
	if what == NOTIFICATION_PREDELETE:
		teardown()

func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint(): return
	if not is_on_floor(): velocity.y += entity_data.config.gravity * delta
	move_and_slide()
	if state_machine.current_state == state_machine.states[State.PATROL] and is_on_wall():
		entity_data.facing_direction *= -1.0

# --- Public Methods ---

func teardown() -> void:
	set_physics_process(false)
	if is_instance_valid(health_component):
		if health_component.health_changed.is_connected(_on_health_component_health_changed):
			health_component.health_changed.disconnect(_on_health_component_health_changed)
		if health_component.died.is_connected(_on_health_component_died):
			health_component.died.disconnect(_on_health_component_died)
		if health_component.health_threshold_reached.is_connected(_on_health_threshold_reached):
			health_component.health_threshold_reached.disconnect(_on_health_threshold_reached)
		if health_component.took_damage.is_connected(_on_health_component_took_damage):
			health_component.took_damage.disconnect(_on_health_component_took_damage)
	
	super.teardown()
	entity_data = null

func get_health_thresholds() -> Array[float]:
	return [phase_2_threshold, phase_3_threshold]

func fire_volley(shot_count: int, delay: float) -> void:
	if is_instance_valid(_active_attack_tween): _active_attack_tween.kill()
	_active_attack_tween = get_tree().create_tween()
	for i in range(shot_count):
		_active_attack_tween.tween_callback(fire_shot_at_player)
		if i < shot_count - 1: _active_attack_tween.tween_interval(delay)

func fire_shot_at_player() -> void:
	if _is_dead or not is_instance_valid(_player): return
	var shot = ObjectPool.get_instance(Identifiers.Pools.BOSS_SHOTS)
	if not shot: return
	_update_player_tracking()
	shot.direction = (_player.global_position - global_position).normalized()
	shot.global_position = global_position
	shot.activate()

# --- Private Methods ---

func _die() -> void:
	if _is_dead: return
	if is_instance_valid(death_shake_effect):
		FXManager.request_screen_shake(death_shake_effect)
	FXManager.request_hit_stop(entity_data.config.boss_death_hit_stop_duration)
	_is_dead = true
	if is_instance_valid(_active_attack_tween): _active_attack_tween.kill()
	set_physics_process(false)
	hide()
	EventBus.emit(EventCatalog.BOSS_DIED, {"boss_node": self})

func _initialize_data() -> void:
	add_to_group(Identifiers.Groups.ENEMY)
	visual_sprite.color = Palette.COLOR_BOSS_PRIMARY
	current_attack_patterns = phase_1_patterns
	entity_data = BossStateData.new()
	entity_data.config = COMBAT_CONFIG

func _initialize_and_setup_components() -> void:
	var shared_deps := {
		"data_resource": entity_data,
		"config": entity_data.config
	}
	
	var states = {
		State.IDLE: state_idle_script.new(self, state_machine, entity_data),
		State.ATTACK: state_attack_script.new(self, state_machine, entity_data),
		State.COOLDOWN: state_cooldown_script.new(self, state_machine, entity_data),
		State.PATROL: state_patrol_script.new(self, state_machine, entity_data),
		State.LUNGE: state_lunge_script.new(self, state_machine, entity_data),
	}
	
	var per_component_deps := {
		state_machine: {"states": states, "initial_state_key": State.COOLDOWN},
		fx_component: {"visual_node": visual_sprite, "health_component": health_component}
	}
	
	setup_components(shared_deps, per_component_deps)

func _connect_signals() -> void:
	health_component.health_changed.connect(_on_health_component_health_changed)
	health_component.died.connect(_on_health_component_died)
	health_component.health_threshold_reached.connect(_on_health_threshold_reached)
	health_component.took_damage.connect(_on_health_component_took_damage)

func _update_player_tracking() -> void:
	if is_instance_valid(_player):
		var dir_to_player = _player.global_position.x - global_position.x
		if not is_zero_approx(dir_to_player):
			entity_data.facing_direction = sign(dir_to_player)
	self.scale.x = entity_data.facing_direction

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
		if is_instance_valid(phase_change_shake_effect):
			FXManager.request_screen_shake(phase_change_shake_effect)
		FXManager.request_hit_stop(entity_data.config.boss_phase_change_hit_stop_duration)
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
	_die()
func _on_health_component_took_damage(damage_info: DamageInfo, _damage_result: DamageResult) -> void:
	if is_instance_valid(hit_spark_effect):
		FXManager.play_vfx(hit_spark_effect, damage_info.impact_position, damage_info.impact_normal)
