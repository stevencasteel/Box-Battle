# src/vfx/hit_spark.gd
## A self-cleaning, poolable particle effect for hit sparks.
class_name HitSpark
extends GPUParticles2D

var _services: ServiceLocator


# --- Godot Lifecycle Methods ---


func _ready() -> void:
	self.finished.connect(_on_finished)


# --- Public Methods (IPoolable Contract) ---


## Activates the particle effect.
func activate(dependencies: Dictionary) -> void:
	_services = dependencies.get("services")
	assert(is_instance_valid(_services), "HitSpark requires a ServiceLocator dependency.")
	var direction = dependencies.get("direction", Vector2.RIGHT)

	process_mode = PROCESS_MODE_INHERIT
	visible = true
	self.rotation = direction.angle()
	restart()


## Deactivates the particle effect.
func deactivate() -> void:
	process_mode = PROCESS_MODE_DISABLED
	visible = false
	_services = null


# --- Signal Handlers ---


func _on_finished() -> void:
	if not is_instance_valid(_services):
		# This might happen if deactivated during a scene transition.
		return

	_services.object_pool.return_instance(self)