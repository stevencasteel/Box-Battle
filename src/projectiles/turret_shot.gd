# src/projectiles/turret_shot.gd
# The projectile for the Turret minion.
extends Area2D

@onready var collision_shape: CollisionShape2D = $CollisionShape2D

var direction = Vector2.LEFT
var speed = 500.0
var damage = 1

func _ready():
	add_to_group("enemy_projectile")
	$ColorRect.color = Palette.COLOR_UI_ACCENT_PRIMARY

func activate():
	process_mode = PROCESS_MODE_INHERIT
	collision_shape.disabled = false

func deactivate():
	process_mode = PROCESS_MODE_DISABLED
	collision_shape.disabled = true
	global_position = Vector2(-1000, -1000)

func _physics_process(delta):
	global_position += direction * speed * delta

func _on_body_entered(body):
	var damageable = CombatUtils.find_damageable(body)
	if damageable:
		damageable.apply_damage(damage, self)
	
	ObjectPool.return_instance(self)

func _on_screen_exited():
	ObjectPool.return_instance(self)
