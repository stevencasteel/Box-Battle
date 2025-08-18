# src/projectiles/boss_shot.gd
## A projectile fired by the boss. Implements the [IPoolable] interface.
class_name BossShot
extends Area2D

# --- Node References ---
@onready var collision_shape: CollisionShape2D = $CollisionShape2D

# --- Member Variables ---
var direction: Vector2 = Vector2.LEFT
var speed: float = 400.0

# --- Godot Lifecycle Methods ---

func _ready() -> void:
	$ColorRect.color = Palette.COLOR_HAZARD_PRIMARY
	add_to_group(Identifiers.Groups.ENEMY_PROJECTILE)

func _physics_process(delta: float) -> void:
	global_position += direction * speed * delta

# --- Public Methods (IPoolable Contract) ---

## Activates the projectile, making it visible and interactive.
func activate() -> void:
	visible = true
	process_mode = PROCESS_MODE_INHERIT
	collision_shape.disabled = false

## Deactivates the projectile, preparing it to be returned to the ObjectPool.
func deactivate() -> void:
	visible = false
	process_mode = PROCESS_MODE_DISABLED
	collision_shape.disabled = true

# --- Signal Handlers ---

func _on_screen_exited() -> void:
	ObjectPool.return_instance.call_deferred(self)