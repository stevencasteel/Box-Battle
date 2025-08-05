# src/projectiles/player_shot.gd
#
# Controls the behavior of the player's charged projectile.
extends Area2D

var direction = Vector2.RIGHT
var speed = 1000.0
var damage = 2 # Charged shots do more damage than melee

func _ready():
	# Connect signals to handle collisions with both solid bodies and other areas.
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func _physics_process(delta):
	position += direction * speed * delta

func _on_body_entered(body):
	# Check if the body hit is an enemy.
	if body.is_in_group("enemy"):
		body.take_damage(damage)
		queue_free() # Destroy self on hit.
		return # Stop further processing.

	# Check if the body hit is part of the solid world.
	if body.is_in_group("world"):
		queue_free() # Destroy self on hitting a wall.

# This function is called when this projectile's area overlaps with another Area2D.
func _on_area_entered(area):
	# Check if the area we hit is an enemy projectile.
	if area.is_in_group("enemy_projectile"):
		# Destroy both this projectile and the enemy one.
		queue_free()
		area.queue_free()