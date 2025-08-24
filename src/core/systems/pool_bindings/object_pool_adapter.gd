# src/core/systems/pool_bindings/object_pool_adapter.gd
## An adapter that implements the IObjectPool interface by delegating calls
## to the real ObjectPool autoload singleton.
extends IObjectPool

# --- Private Member Variables ---
var _real_object_pool: Node

# --- Godot Lifecycle Methods ---
func _ready() -> void:
	_real_object_pool = get_node("/root/ObjectPool")
	assert(is_instance_valid(_real_object_pool), "ObjectPoolAdapter could not find /root/ObjectPool")

# --- IObjectPool Implementation ---

func get_instance(pool_name: StringName) -> Node:
	return _real_object_pool.get_instance(pool_name)

func return_instance(instance: Node) -> void:
	_real_object_pool.return_instance(instance)

func reset() -> void:
	_real_object_pool.reset()

func get_pool_stats() -> Dictionary:
	return _real_object_pool.get_pool_stats()