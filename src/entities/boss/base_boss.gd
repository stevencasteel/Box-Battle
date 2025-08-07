# src/entities/boss/base_boss.gd
#
# This is the foundational script for all bosses in the game. It handles
# shared logic like health, taking damage, gravity, and a basic attack
# cycle managed by a state machine.
extends CharacterBody2D

# --- Signals ---
signal health_changed(current_health, max_health)
signal died

# --- Node References ---
@onready var visual_sprite: ColorRect = $ColorRect
@onready var cooldown_timer: Timer = $CooldownTimer
@onready var patrol_timer: Timer = $PatrolTimer
@onready var hit_flash_timer: Timer = $HitFlashTimer

# --- Preloads ---
const BossShotScene = preload(AssetPaths.SCENE_BOSS_SHOT)

# --- State Machine ---
enum State { IDLE, ATTACK, COOLDOWN, PATROL }
var state: State = State.IDLE

# --- Boss Stats & Properties ---
var health = Constants.BOSS_HEALTH
var player: CharacterBody2D = null
var facing_direction = -1.0
var patrol_speed = 100.0
var original_color: Color

# --- Attack Definitions ---
enum AttackPattern { SINGLE_SHOT, VOLLEY_SHOT }
var current_attack: AttackPattern

# --- Engine Functions ---

func _ready():
	add_to_group("enemy")
	original_color = visual_sprite.color # Store the starting color
	player = get_tree().get_first_node_in_group("player")
	health_changed.emit(health, Constants.BOSS_HEALTH)
	change_state(State.COOLDOWN)

func _physics_process(delta):
	if not is_on_floor():
		velocity.y += Constants.GRAVITY * delta

	_update_player_tracking()

	match state:
		State.IDLE:
			state_idle(delta)
		State.ATTACK:
			state_attack(delta)
		State.COOLDOWN:
			state_cooldown(delta)
		State.PATROL:
			state_patrol(delta)

	move_and_slide()
	
	if state == State.PATROL and is_on_wall():
		facing_direction *= -1.0

# --- State Functions ---

func state_idle(_delta):
	velocity.x = 0
	change_state(State.ATTACK)

func state_attack(_delta):
	match current_attack:
		AttackPattern.SINGLE_SHOT:
			fire_shot_at_player()
		AttackPattern.VOLLEY_SHOT:
			var tween = get_tree().create_tween()
			tween.tween_callback(fire_shot_at_player)
			tween.tween_interval(0.2)
			tween.tween_callback(fire_shot_at_player)
			tween.tween_interval(0.2)
			tween.tween_callback(fire_shot_at_player)
	change_state(State.COOLDOWN)

func state_cooldown(_delta):
	velocity.x = 0
	pass

func state_patrol(_delta):
	velocity.x = facing_direction * patrol_speed

# --- Core Logic ---

func _update_player_tracking():
	if state == State.ATTACK:
		if is_instance_valid(player):
			var direction_to_player = player.global_position.x - global_position.x
			if not is_zero_approx(direction_to_player):
				facing_direction = sign(direction_to_player)
	
	self.scale.x = facing_direction
	
func fire_shot_at_player():
	if not is_instance_valid(player): return
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

func _trigger_hit_flash():
	visual_sprite.color = Color.DODGER_BLUE
	hit_flash_timer.start()

func change_state(new_state: State):
	if state == new_state:
		return
	state = new_state
	print("Boss entering state: ", State.keys()[new_state])
	match new_state:
		State.ATTACK:
			var attack_keys = AttackPattern.keys()
			var chosen_attack_name = attack_keys[randi() % attack_keys.size()]
			current_attack = AttackPattern[chosen_attack_name]
			print("Boss chose attack: ", chosen_attack_name)
		State.COOLDOWN:
			cooldown_timer.start()
		State.PATROL:
			patrol_timer.start()

# --- Signal Callbacks ---

func _on_hit_flash_timer_timeout():
	visual_sprite.color = original_color

func _on_cooldown_timer_timeout():
	if state == State.COOLDOWN:
		change_state(State.PATROL)

func _on_patrol_timer_timeout():
	if state == State.PATROL:
		change_state(State.IDLE)