# src/entities/boss/base_boss.gd
# This is the "Context" script for the Boss State Machine. It now delegates
# state and health management to its data resource and component.
extends CharacterBody2D

# --- Signals ---
signal health_changed(current_health, max_health)
signal died

# --- Enums ---
enum State { IDLE, ATTACK, COOLDOWN, PATROL }
enum AttackPattern { SINGLE_SHOT, VOLLEY_SHOT }

# --- Node References ---
@onready var visual_sprite: ColorRect = $ColorRect
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var patrol_timer: Timer = $PatrolTimer
@onready var health_component: HealthComponent = $HealthComponent

# --- State Machine & Data ---
var states: Dictionary
var current_state: BossState
var b_data: BossStateData

# --- Boss Properties ---
var player: CharacterBody2D = null

# --- Engine Functions ---
func _ready():
	b_data = BossStateData.new()
	# MODIFIED: Get value from the new CombatDB resource.
	b_data.patrol_speed = CombatDB.config.boss_patrol_speed
	
	visual_sprite.color = Palette.COLOR_BOSS_PRIMARY
	
	# MODIFIED: Pass the typed resource directly to the component.
	health_component.setup(b_data, self, CombatDB.config)
	health_component.health_changed.connect(_on_health_component_health_changed)
	health_component.died.connect(_on_health_component_died)

	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player")
	
	states = {
		State.IDLE: BossStateIdle.new(self, b_data),
		State.ATTACK: BossStateAttack.new(self, b_data),
		State.COOLDOWN: BossStateCooldown.new(self, b_data),
		State.PATROL: BossStatePatrol.new(self, b_data),
	}
	
	change_state(State.COOLDOWN)

func _physics_process(delta):
	if not is_on_floor():
		# MODIFIED: Get value from the new CombatDB resource.
		velocity.y += CombatDB.config.gravity * delta

	if current_state:
		current_state.process_physics(delta)
	
	move_and_slide()
	
	if states.find_key(current_state) == State.PATROL and is_on_wall():
		b_data.facing_direction *= -1.0

func _exit_tree():
	EventBus.off_owner(self)
	states.clear()
	b_data = null
	health_component = null

func change_state(new_state_key: State):
	if not states.has(new_state_key): return
	if current_state == states[new_state_key]: return
	if current_state: current_state.exit()
	
	current_state = states[new_state_key]
	current_state.enter()

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
	if states.find_key(current_state) == State.COOLDOWN:
		change_state(State.PATROL)

func _on_patrol_timer_timeout():
	if states.find_key(current_state) == State.PATROL:
		change_state(State.IDLE)
		
func _on_health_component_health_changed(current, max_val):
	var ev = BossHealthChangedEvent.new()
	ev.current_health = current
	ev.max_health = max_val
	EventBus.emit(EventCatalog.BOSS_HEALTH_CHANGED, ev, self)
	health_changed.emit(current, max_val)

func _on_health_component_died():
	die()
