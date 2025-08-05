# src/entities/boss/base_boss.gd
#
# This is the foundational script for all bosses in the game. It handles
# shared logic like health, taking damage, gravity, and a basic attack.
extends CharacterBody2D

# Preload the projectile scene using the safe path from our singleton.
const BossShotScene = preload(AssetPaths.SCENE_BOSS_SHOT)

# --- Boss Stats ---
var health = Constants.BOSS_HEALTH

func _ready():
	# Add to the "enemy" group so the player's attacks can find it.
	add_to_group("enemy")

func _physics_process(delta):
	# Apply gravity if the boss is not on the floor.
	if not is_on_floor():
		velocity.y += Constants.GRAVITY * delta
	move_and_slide()

# This function is called by the player's attacks.
func take_damage(damage_amount: int):
	health -= damage_amount
	print("Boss took ", damage_amount, " damage! Health remaining: ", health)
	if health <= 0:
		die()

func die():
	print("Boss has been defeated!")
	# We can add animations and effects here later.
	queue_free()

# --- Attack Logic ---
# This function is connected to the ShotTimer's timeout signal.
func _on_shot_timer_timeout():
	fire_shot()

func fire_shot():
	var shot_instance = BossShotScene.instantiate()
	# Spawn the shot 50 pixels to the left of the boss's center.
	shot_instance.position = global_position + Vector2(-50, 0)
	# Add the shot to the main game scene tree.
	get_parent().add_child(shot_instance)