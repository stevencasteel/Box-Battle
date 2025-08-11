# src/entities/boss/base_boss.gd
# This is the "Context" for the Boss State Machine. It now loads a list
# of AttackPattern resources for its states to use.
extends CharacterBody2D

# --- Signals ---
signal health_changed(current_health, max_health)
signal died

# --- Enums ---
enum State { IDLE, ATTACK, COOLDOWN, PATROL }
# REMOVED: AttackPattern enum is no longer needed; it's data-driven.

# --- Node References ---
@onready var visual_sprite: ColorRect = $ColorRect
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var patrol_timer: Timer = $PatrolTimer
@onready var health_component: HealthComponent = $HealthComponent
@onready var state_machine: BaseStateMachine = $StateMachine

# --- Data ---
var b_data: BossStateData

# --- Boss Properties ---
var player: CharacterBody2D = null
# NEW: An array to hold our AttackPattern resources.
var attack_patterns: Array[AttackPattern] = []

# --- Engine Functions ---
func _ready():
	add_to_group("enemy")
	
	# NEW: Load all attack patterns into the array.
	attack_patterns.append(load("res://src/entities/boss/attack_patterns/single_shot.tres"))
	attack_patterns.append(load("res://src/entities/boss/attack_patterns/volley_shot.tres"))
	
	b_data = BossStateData.new()
	b_data.patrol_speed = CombatDB.config.boss_patrol_speed
	
	visual_sprite.color = Palette.COLOR_BOSS_PRIMARY
	
	health_component.setup(self, {
		"data_resource": b_data,
		"config": CombatDB.config
	})
	health_component.health_changed.connect(_on_health_component_health_changed)
	health_component.died.connect(_on_health_component_died)

	player = get_tree().get_first_node_in_group("player")
	
	var states = {
		State.IDLE: BossStateIdle.new(self, state_machine, b_data),
		State.ATTACK: BossStateAttack.new(self, state_machine, b_data),
		State.COOLDOWN: BossStateCooldown.new(self, state_machine, b_data),
		State.PATROL: BossStatePatrol.new(self, state_machine, b_data),
	}
	
	state_machine.setup(states, State.COOLDOWN)

func _notification(what):
	if what == NOTIFICATION_PREDELETE:
		if state_machine: state_machine.teardown()
		if health_component: health_component.teardown()
		b_data = null

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += CombatDB.config.gravity * delta
	
	move_and_slide()
	
	if state_machine.current_state == state_machine.states[State.PATROL] and is_on_wall():
		b_data.facing_direction *= -1.0

# --- Public Methods ---
func die():
	died.emit()
	queue_free()

# --- Internal Functions ---
func _update_player_tracking():
	if is_instance_valid(player):
		var direction_to_player = player.global_position.x - global_position.x
		if not is_zero_approx(direction_to_player):
			b_data.facing_direction = sign(direction_to_player)
	self.scale.x = b_data.facing_direction
	
func fire_shot_at_player():
	if not is_instance_valid(player): return
	
	var shot_instance = ObjectPool.get_instance(&"boss_shots")
	if not shot_instance: return
	
	_update_player_tracking()
	var direction_to_player = (player.global_position - global_position).normalized()
	shot_instance.direction = direction_to_player
	
	shot_instance.global_position = global_position
	shot_instance.activate()
	
# --- Signal Handlers ---
func _on_cooldown_timer_timeout():
	if state_machine.current_state == state_machine.states[State.COOLDOWN]:
		state_machine.change_state(State.PATROL)

func _on_patrol_timer_timeout():
	if state_machine.current_state == state_machine.states[State.PATROL]:
		state_machine.change_state(State.IDLE)
		
func _on_health_component_health_changed(current, max_val):
	var ev = BossHealthChangedEvent.new()
	ev.current_health = current
	ev.max_health = max_val
	EventBus.emit(EventCatalog.BOSS_HEALTH_CHANGED, ev)
	health_changed.emit(current, max_val)

func _on_health_component_died():
	die()
