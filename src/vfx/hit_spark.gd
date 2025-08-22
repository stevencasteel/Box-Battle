# src/vfx/hit_spark.gd
## A self-cleaning, poolable particle effect for hit sparks.
class_name HitSpark
extends GPUParticles2D

# --- Godot Lifecycle Methods ---


func _ready() -> void:
	self.finished.connect(_on_finished)


# --- Public Methods (IPoolable Contract) ---


## Activates the particle effect.
func activate(direction: Vector2 = Vector2.RIGHT) -> void:
	process_mode = PROCESS_MODE_INHERIT
	visible = true
	self.rotation = direction.angle()
	restart()


## Deactivates the particle effect.
func deactivate() -> void:
	process_mode = PROCESS_MODE_DISABLED
	visible = false


# --- Signal Handlers ---


func _on_finished() -> void:
	ObjectPool.return_instance(self)
