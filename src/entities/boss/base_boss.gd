# src/entities/boss/base_boss.gd
# The boss now correctly tears down its components to prevent memory leaks.
class_name BaseBoss
extends CharacterBody2D

enum State { IDLE, ATTACK, COOLDOWN, PATROL, LUNGE }

@onready var visual_sprite: ColorRect = $ColorRect
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var patrol_timer: Timer = $PatrolTimer
@onready var health_component: HealthComponent = $HealthComponent
@onready var state_machine: BaseStateMachine = $StateMachine
@onready var armor_component: ArmorComponent = $ArmorComponent

var b_data: BossStateData
var player: CharacterBody2D = null

var phases_remaining: int = 3
@export var phase_2_threshold: float = 0.7
@export var phase_3_threshold: float = 0.4

var phase_1_patterns: Array[AttackPattern] = []
var phase_2_patterns: Array[AttackPattern] = []
var phase_3_patterns: Array[AttackPattern] = []
var current_attack_patterns: Array[AttackPattern] = []

var _active_attack_tween: Tween
var _is_dead: bool = false

func _ready():
	add_to_group("enemy")
	
	var single_shot = load("res://src/entities/boss/attack_patterns/single_shot.tres")
	var volley_shot = load("res://src/entities/boss/attack_patterns/volley_shot.tres")
	var lunge_attack = load("res://src/entities/boss/attack_patterns/lunge_attack.tres")
	
	phase_1_patterns = [single_shot, volley_shot]
	
	var single_shot_p2 = single_shot.duplicate(); single_shot_p2.cooldown *= 0.8
	var volley_shot_p2 = volley_shot.duplicate(); volley_shot_p2.cooldown *= 0.8
	phase_2_patterns = [single_shot_p2, volley_shot_p2, lunge_attack]

	var volley_shot_p3 = volley_shot_p2.duplicate(); volley_shot_p3.cooldown *= 0.8
	var lunge_attack_p3 = lunge_attack.duplicate(); lunge_attack_p3.cooldown *= 0.9
	phase_3_patterns = [volley_shot_p3, lunge_attack_p3]
	
	current_attack_patterns = phase_1_patterns
	
	b_data = BossStateData.new()
	b_data.patrol_speed = CombatDB.config.boss_patrol_speed
	visual_sprite.color = Palette.COLOR_BOSS_PRIMARY
	health_component.setup(self, { "data_resource": b_data, "config": CombatDB.config })
	health_component.health_changed.connect(_on_health_component_health_changed)
	health_component.died.connect(_on_health_component_died)
	health_component.health_threshold_reached.connect(_on_health_threshold_reached)
	player = get_tree().get_first_node_in_group("player")
	
	var states = {
		State.IDLE: BossStateIdle.new(self, state_machine, b_data),
		State.ATTACK: BossStateAttack.new(self, state_machine, b_data),
		State.COOLDOWN: BossStateCooldown.new(self, state_machine, b_data),
		State.PATROL: BossStatePatrol.new(self, state_machine, b_data),
		State.LUNGE: BossStateLunge.new(self, state_machine, b_data),
	}
	state_machine.setup(states, State.COOLDOWN)

# THE FIX: This function now ensures all components are safely torn down.
func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if is_instance_valid(_active_attack_tween): _active_attack_tween.kill()
		if is_instance_valid(state_machine): state_machine.teardown()
		if is_instance_valid(health_component): health_component.teardown()
		b_data = null

func _physics_process(delta):
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
		
		print("VERIFICATION: Boss has ", phases_remaining, " phases remaining.")
		EventBus.emit(EventCatalog.BOSS_PHASE_CHANGED, {"phases_remaining": phases_remaining})

func _on_cooldown_timer_timeout():
	if state_machine.current_state == state_machine.states[State.COOLDOWN]: state_machine.change_state(State.PATROL)
func _on_patrol_timer_timeout():
	if state_machine.current_state == state_machine.states[State.PATROL]: state_machine.change_state(State.IDLE)
func _on_health_component_health_changed(current, max_val):
	var ev = BossHealthChangedEvent.new(); ev.current_health = current; ev.max_health = max_val
	EventBus.emit(EventCatalog.BOSS_HEALTH_CHANGED, ev)
func _on_health_component_died(): die()
