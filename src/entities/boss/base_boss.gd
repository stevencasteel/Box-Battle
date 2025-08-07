# src/entities/boss/base_boss.gd
# This is the "Context" script for the Boss State Machine. It holds all
# shared data and delegates all per-frame logic to its current state object.
extends CharacterBody2D

# --- Signals ---
signal health_changed(current_health, max_health)
signal died

# --- State Machine Enum (Globally Accessible as BaseBoss.State) ---
enum State { IDLE, ATTACK, COOLDOWN, PATROL }
enum AttackPattern { SINGLE_SHOT, VOLLEY_SHOT }

# --- Node References ---
@onready var visual_sprite: ColorRect = $ColorRect
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var patrol_timer: Timer = $PatrolTimer
@onready var hit_flash_timer: Timer = $HitFlashTimer

# --- Preloads ---
const BossShotScene = preload(AssetPaths.SCENE_BOSS_SHOT)
# REFINEMENT: Removed preload constants for states as they are now global classes.

# --- State Machine ---
var states: Dictionary
var current_state: BossState

# --- Boss Stats & Properties (Shared Data) ---
var health = Constants.BOSS_HEALTH
var player: CharacterBody2D = null
var facing_direction = -1.0
var patrol_speed = 100.0
var original_color: Color
var current_attack: AttackPattern

# --- Engine Functions ---
func _ready():
	add_to_group("enemy")
	original_color = visual_sprite.color
	player = get_tree().get_first_node_in_group("player")
	
	# REFINEMENT: Initialize states using their global class names.
	states = {
		State.IDLE: BossStateIdle.new(self),
		State.ATTACK: BossStateAttack.new(self),
		State.COOLDOWN: BossStateCooldown.new(self),
		State.PATROL: BossStatePatrol.new(self),
	}
	
	change_state(State.COOLDOWN)
	health_changed.emit(health, Constants.BOSS_HEALTH)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += Constants.GRAVITY * delta

	if current_state:
		current_state.process_physics(delta)
	
	move_and_slide()
	
	if states.find_key(current_state) == State.PATROL and is_on_wall():
		facing_direction *= -1.0

# --- State Management ---
func change_state(new_state_key: State):
	if not states.has(new_state_key):
		print("Boss state key not found: ", new_state_key)
		return
	if current_state == states[new_state_key]:
		return
		
	if current_state:
		current_state.exit()
	
	current_state = states[new_state_key]
	print("Boss entering state: ", State.keys()[new_state_key])
	current_state.enter()

# --- Helper Functions (used by states) ---
func _update_player_tracking():
	if is_instance_valid(player):
		var direction_to_player = player.global_position.x - global_position.x
		if not is_zero_approx(direction_to_player):
			facing_direction = sign(direction_to_player)
	self.scale.x = facing_direction
	
func fire_shot_at_player():
	if not is_instance_valid(player): return
	_update_player_tracking()
	var shot_instance = BossShotScene.instantiate()
	get_parent().add_child(shot_instance)
	shot_instance.global_position = global_position
	var direction_to_player = (player.global_position - global_position).normalized()
	shot_instance.direction = direction_to_player
	
func take_damage(damage_amount: int):
	health -= damage_amount
	health_changed.emit(health, Constants.BOSS_HEALTH)
	_trigger_hit_flash()
	print("Boss took ", damage_amount, " damage! Health remaining: ", health)
	if health <= 0:
		die()

func die():
	print("Boss has been defeated!")
	died.emit()
	queue_free()

func _trigger_hit_flash():
	visual_sprite.color = Color.DODGER_BLUE
	hit_flash_timer.start()

# --- Signal Callbacks (handle state transitions) ---
func _on_hit_flash_timer_timeout():
	visual_sprite.color = original_color

func _on_cooldown_timer_timeout():
	if states.find_key(current_state) == State.COOLDOWN:
		change_state(State.PATROL)

func _on_patrol_timer_timeout():
	if states.find_key(current_state) == State.PATROL:
		change_state(State.IDLE)
