# src/entities/boss/base_boss.gd
#
# This is the foundational script for all bosses in the game. It handles
# shared logic like health, taking damage, gravity, and a basic attack
# cycle managed by a state machine.
extends CharacterBody2D

# --- Node References ---
# We no longer need a direct reference to the ColorRect for flipping.
@onready var shot_timer: Timer = $ShotTimer

# --- Preloads ---
const BossShotScene = preload(AssetPaths.SCENE_BOSS_SHOT)

# --- State Machine ---
enum State { IDLE, ATTACK, COOLDOWN }
var state: State = State.IDLE

# --- Boss Stats & Properties ---
var health = Constants.BOSS_HEALTH
var player: CharacterBody2D = null
var facing_direction = -1.0 # Start facing left

# --- Attack Definitions ---
enum AttackPattern { SINGLE_SHOT, VOLLEY_SHOT }
var current_attack: AttackPattern

# --- Engine Functions ---

func _ready():
	add_to_group("enemy")
	player = get_tree().get_first_node_in_group("player")
	# We now use the timer as a general-purpose cooldown timer.
	shot_timer.wait_time = 1.5 # Cooldown duration after an attack.
	shot_timer.one_shot = true # It should only fire once per cooldown cycle.
	change_state(State.COOLDOWN) # Start with an initial cooldown.

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

	move_and_slide()

# --- State Functions ---

func state_idle(_delta):
	# From IDLE, we immediately decide on an attack and execute it.
	change_state(State.ATTACK)

func state_attack(_delta):
	# Execute the chosen attack pattern.
	match current_attack:
		AttackPattern.SINGLE_SHOT:
			fire_shot_at_player()
		AttackPattern.VOLLEY_SHOT:
			# Use a SceneTreeTween to fire 3 shots with a small delay between them.
			var tween = get_tree().create_tween()
			tween.tween_callback(fire_shot_at_player)
			tween.tween_interval(0.2)
			tween.tween_callback(fire_shot_at_player)
			tween.tween_interval(0.2)
			tween.tween_callback(fire_shot_at_player)

	# After initiating the attack, go into cooldown.
	change_state(State.COOLDOWN)

func state_cooldown(_delta):
	# The boss does nothing during cooldown. The timer's timeout signal
	# will be responsible for transitioning out of this state.
	pass


# --- Core Logic ---

func _update_player_tracking():
	if not is_instance_valid(player):
		return
		
	# Determine direction based on player's position.
	var direction_to_player = player.global_position.x - global_position.x
	if not is_zero_approx(direction_to_player):
		facing_direction = sign(direction_to_player)
	
	# THE FIX: Flip the entire boss node. This ensures all children,
	# including the collision shape, flip together.
	self.scale.x = facing_direction

func fire_shot_at_player():
	if not is_instance_valid(player):
		return

	var shot_instance = BossShotScene.instantiate()
	get_parent().add_child(shot_instance)
	shot_instance.global_position = global_position
	
	var direction_to_player = (player.global_position - global_position).normalized()
	shot_instance.direction = direction_to_player

func take_damage(damage_amount: int):
	health -= damage_amount
	print("Boss took ", damage_amount, " damage! Health remaining: ", health)
	if health <= 0:
		die()

func die():
	print("Boss has been defeated!")
	queue_free()

func change_state(new_state: State):
	if state == new_state:
		return
	
	state = new_state
	print("Boss entering state: ", State.keys()[new_state])

	# "On Enter" logic for each state
	match new_state:
		State.ATTACK:
			# Randomly select an attack pattern when entering the ATTACK state.
			var attack_keys = AttackPattern.keys()
			var chosen_attack_name = attack_keys[randi() % attack_keys.size()]
			current_attack = AttackPattern[chosen_attack_name]
			print("Boss chose attack: ", chosen_attack_name)
		State.COOLDOWN:
			# When entering COOLDOWN, start the timer.
			shot_timer.start()


# --- Signal Callbacks ---

func _on_shot_timer_timeout():
	# When the cooldown timer finishes, the boss becomes idle and ready to attack.
	if state == State.COOLDOWN:
		change_state(State.IDLE)