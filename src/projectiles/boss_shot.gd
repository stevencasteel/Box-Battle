# src/projectiles/boss_shot.gd
#
# Controls the behavior of the boss's projectile.
extends Area2D

@onready var visual_sprite: ColorRect = $ColorRect

var direction = Vector2.LEFT
var speed = 400.0

func _ready():
	# PALETTE INTEGRATION: Set the projectile's color from the Palette.
	# We use the primary hazard color to communicate that this is dangerous.
	visual_sprite.color = Palette.COLOR_HAZARD_PRIMARY

	# This projectile's purpose is to be detected by the player's hurtbox.
	# The physics layers are set in the scene file.
	add_to_group("enemy_projectile")

func _physics_process(delta):
	position += direction * speed * delta

# This function is not used because the projectile itself doesn't need to detect
# things. Instead, the player's hurtbox detects this projectile. We leave the
# Area2D's monitoring property on by default, but we don't connect its signals.