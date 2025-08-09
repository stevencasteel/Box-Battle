# src/projectiles/boss_shot.gd
#
# Final, stable pool-aware version.
extends Area2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var direction = Vector2.LEFT
var speed = 400.0

func _ready():
	$ColorRect.color = Palette.COLOR_HAZARD_PRIMARY
	add_to_group("enemy_projectile")

func activate():
	process_mode = PROCESS_MODE_INHERIT
	collision_shape.disabled = false

func deactivate():
	process_mode = PROCESS_MODE_DISABLED
	collision_shape.disabled = true
	global_position = Vector2(-1000, -1000) # Move to the graveyard

func _physics_process(delta):
	global_position += direction * speed * delta

func _on_screen_exited():
	ObjectPool.return_instance(self)