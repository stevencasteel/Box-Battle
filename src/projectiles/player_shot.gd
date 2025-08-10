# src/projectiles/player_shot.gd
#
# Final, stable pool-aware version.
extends Area2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var direction = Vector2.RIGHT
var speed = 1000.0
var damage = 2

func _ready():
	$ColorRect.color = Palette.COLOR_PLAYER_PROJECTILE
	body_entered.connect(_on_body_entered)
	area_entered.connect(_on_area_entered)

func activate():
	process_mode = PROCESS_MODE_INHERIT
	collision_shape.disabled = false

func deactivate():
	process_mode = PROCESS_MODE_DISABLED
	collision_shape.disabled = true
	global_position = Vector2(-1000, -1000) # Move to the graveyard

func _physics_process(delta):
	global_position += direction * speed * delta

# SOLUTION: This function now correctly finds and calls take_damage on the
# enemy's HealthComponent, aligning it with the final architecture.
func _on_body_entered(body):
	if body.is_in_group("enemy"):
		var enemy_health_comp = body.get_node_or_null("HealthComponent")
		if enemy_health_comp:
			enemy_health_comp.take_damage(damage, self)
	
	ObjectPool.return_instance(self)

func _on_area_entered(area):
	if area.is_in_group("enemy_projectile"):
		ObjectPool.return_instance(area)
	ObjectPool.return_instance(self)

func _on_screen_exited():
	ObjectPool.return_instance(self)