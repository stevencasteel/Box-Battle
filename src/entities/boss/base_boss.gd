# src/entities/boss/base_boss.gd
# This script now correctly uses a preloaded utility with static functions
# for its in-editor validation checks.
@tool
class_name BaseBoss
extends CharacterBody2D

# THE FIX: Preload the validator script to make its static functions available.
const Validator = preload("res://src/core/util/scene_validator.gd")

enum State { IDLE, ATTACK, COOLDOWN, PATROL, LUNGE }

# --- Node References ---
var visual_sprite: ColorRect
var cooldown_timer: Timer
var patrol_timer: Timer
var health_component: HealthComponent
var state_machine: BaseStateMachine
var armor_component: ArmorComponent

# --- DATA ---
var b_data: BossStateData
var player: CharacterBody2D = null
var _active_attack_tween: Tween
var _is_dead: bool = false
var phases_remaining: int = 3

# --- EDITOR CONFIGURATION ---
@export_group("Phase Configuration")
@export_range(0.0, 1.0, 0.01) var phase_2_threshold: float = 0.7
@export_range(0.0, 1.0, 0.01) var phase_3_threshold: float = 0.4

@export_group("Attack Patterns")
@export var phase_1_patterns: Array[AttackPattern] = []
@export var phase_2_patterns: Array[AttackPattern] = []
@export var phase_3_patterns: Array[AttackPattern] = []
var current_attack_patterns: Array[AttackPattern] = []

# THE FIX: The validation function is now a simple, direct call.
func _get_configuration_warnings() -> PackedStringArray:
	return Validator.validate_boss_scene(self)

func _ready():
	visual_sprite = $ColorRect
	cooldown_timer = $CooldownTimer
	patrol_timer = $PatrolTimer
	health_component = $HealthComponent
	state_machine = $StateMachine
	armor_component = $ArmorComponent

	if Engine.is_editor_hint(): return

	add_to_group("enemy")
	current_attack_patterns = phase_1_patterns
	
	b_data = BossStateData.new()
	b_data.patrol_speed = CombatDB.config.boss_patrol_speed
	visual_sprite.color = Palette.COLOR_BOSS_PRIMARY
	health_component.setup(self, { "data_resource": b_data, "config": CombatDB.config })
	health_component.health_changed.connect(_on_health_component_health_changed)
	health_component.died.connect(_on_health_component_died)
	health_component.health_threshold_reached.connect(_on_health_threshold_reached)
	
	if get_tree().get_first_node_in_group("player"):
		player = get_tree().get_first_node_in_group("player")
	
	var states = {
		State.IDLE: BossStateIdle.new(self, state_machine, b_data),
		State.ATTACK: BossStateAttack.new(self, state_machine, b_data),
		State.COOLDOWN: BossStateCooldown.new(self, state_machine, b_data),
		State.PATROL: BossStatePatrol.new(self, state_machine, b_data),
		State.LUNGE: BossStateLunge.new(self, state_machine, b_data),
	}
	state_machine.setup(states, State.COOLDOWN)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid(state_machine): state_machine.teardown()
		if is_instance_valid(health_component): health_component.teardown()
		b_data = null

func _physics_process(delta):
	if Engine.is_editor_hint(): return
	if not is_on_floor(): velocity.y += CombatDB.config.gravity * delta
	move_and_slide()
	if state_machine.current_state == state_machine.states[State.PATROL] and is_on_wall():
		b_data.facing_direction *= -1.0

func get_health_thresholds() -> Array[float]: return [phase_2_threshold, phase_3_threshold]

func die():
	if _is_dead: return
	_is_dead = true
	if is_instance_valid(_active_attack_tween): _active_attack_tween.kill()
	set_physics_process(false)
	hide()
	EventBus.emit(EventCatalog.BOSS_DIED, {"boss_node": self})

func fire_volley(shot_count: int):
	if is_instance_valid(_active_attack_tween): _active_attack_tween.kill()
	_active_attack_tween = get_tree().create_tween()
	for i in range(shot_count):
		_active_attack_tween.tween_callback(fire_shot_at_player)
		if i < shot_count - 1: _active_attack_tween.tween_interval(0.2)
	
func _update_player_tracking():
	if is_instance_valid(player):
		var dir_to_player = player.global_position.x - global_position.x
		if not is_zero_approx(dir_to_player): b_data.facing_direction = sign(dir_to_player)
	self.scale.x = b_data.facing_direction
	
func fire_shot_at_player():
	if _is_dead: return
	if not is_instance_valid(player): return
	var shot = ObjectPool.get_instance(&"boss_shots")
	if not shot: return
	_update_player_tracking()
	shot.direction = (player.global_position - global_position).normalized()
	shot.global_position = global_position
	shot.activate()
	
func _on_health_threshold_reached(health_percentage: float):
	var new_phases_remaining = phases_remaining
	if health_percentage <= phase_3_threshold and phases_remaining > 1: new_phases_remaining = 1
	elif health_percentage <= phase_2_threshold and phases_remaining > 2: new_phases_remaining = 2

	if new_phases_remaining != phases_remaining:
		phases_remaining = new_phases_remaining
		match phases_remaining:
			2: current_attack_patterns = phase_2_patterns
			1: current_attack_patterns = phase_3_patterns
		EventBus.emit(EventCatalog.BOSS_PHASE_CHANGED, {"phases_remaining": phases_remaining})

func _on_cooldown_timer_timeout():
	if state_machine.current_state == state_machine.states[State.COOLDOWN]: state_machine.change_state(State.PATROL)
func _on_patrol_timer_timeout():
	if state_machine.current_state == state_machine.states[State.PATROL]: state_machine.change_state(State.IDLE)
func _on_health_component_health_changed(current, max_val):
	var ev = BossHealthChangedEvent.new(); ev.current_health = current; ev.max_health = max_val
	EventBus.emit(EventCatalog.BOSS_HEALTH_CHANGED, ev)
func _on_health_component_died(): die()