# src/core/systems/object_pool.gd
## An autoloaded singleton that manages pools of reusable nodes.
##
## This system prevents performance degradation (stutter) from frequent
## instantiation and deletion of nodes like projectiles and visual effects.
extends Node

# --- Private Member Variables ---
var _pools: Dictionary = {}
var _is_initialized: bool = false

# --- Godot Lifecycle Methods ---


func _ready() -> void:
	# Per SRP, _ready() should be lightweight. Heavy lifting is moved to initialize().
	pass


func _exit_tree() -> void:
	for i in range(get_child_count() - 1, -1, -1):
		var child: Node = get_child(i)
		for j in range(child.get_child_count() - 1, -1, -1):
			child.get_child(j).free()
		child.free()
	_pools.clear()


# --- Public Methods ---


func initialize() -> void:
	if _is_initialized:
		return
	_create_pool_from_path(Identifiers.Pools.PLAYER_SHOTS, AssetPaths.SCENE_PLAYER_SHOT, 15)
	_create_pool_from_path(Identifiers.Pools.BOSS_SHOTS, AssetPaths.SCENE_BOSS_SHOT, 30)
	_create_pool_from_path(Identifiers.Pools.MINION_SHOTS, AssetPaths.SCENE_MINION_SHOT, 20)
	_create_pool_from_path(Identifiers.Pools.HOMING_BOSS_SHOTS, AssetPaths.SCENE_HOMING_BOSS_SHOT, 40)
	_create_pool_from_path(Identifiers.Pools.HIT_SPARKS, AssetPaths.SCENE_HIT_SPARK, 25)
	_is_initialized = true


func get_pool_stats() -> Dictionary:
	var stats: Dictionary = {}
	for pool_name in _pools:
		var pool: Dictionary = _pools[pool_name]
		var total_count: int = pool.container.get_child_count()
		var inactive_count: int = pool.inactive.size()
		stats[pool_name] = {"active": total_count - inactive_count, "total": total_count}
	return stats


func reset() -> void:
	for pool_name in _pools:
		var pool: Dictionary = _pools[pool_name]
		var active_nodes_to_return: Array[Node] = []
		for child in pool.container.get_children():
			if not pool.inactive.has(child):
				active_nodes_to_return.append(child)

		for node in active_nodes_to_return:
			return_instance.call_deferred(node)


func get_instance(p_pool_name: StringName) -> Node:
	if not _pools.has(p_pool_name):
		push_error("ObjectPool: Attempted to get instance from a non-existent pool: '%s'" % p_pool_name)
		return null

	var pool: Dictionary = _pools[p_pool_name]
	var instance: Node

	if not pool.inactive.is_empty():
		instance = pool.inactive.pop_front()
	else:
		instance = pool.scene.instantiate()
		instance.set_meta("pool_name", p_pool_name)
		pool.container.add_child(instance)

	return instance


func return_instance(p_instance: Node) -> void:
	if not is_instance_valid(p_instance):
		return

	var pool_name: StringName = p_instance.get_meta("pool_name", "")
	if pool_name == "" or not _pools.has(pool_name):
		p_instance.queue_free()
		return

	var pool: Dictionary = _pools[pool_name]
	if not pool.inactive.has(p_instance):
		pool.inactive.push_front(p_instance)

	if p_instance.has_method("deactivate"):
		p_instance.deactivate()


# --- Private Methods ---

func _create_pool_from_path(p_pool_name: StringName, p_scene_path: String, p_initial_size: int) -> void:
	var scene: PackedScene = load(p_scene_path)

	if not is_instance_valid(scene):
		push_error("ObjectPool: Failed to load scene for pool '%s' at path: %s" % [p_pool_name, p_scene_path])
		return

	_create_pool_for_scene(p_pool_name, scene, p_initial_size)


func _create_pool_for_scene(
	p_pool_name: StringName, p_scene: PackedScene, p_initial_size: int
) -> void:
	if _pools.has(p_pool_name):
		return

	var pool_container := Node.new()
	pool_container.name = str(p_pool_name)
	add_child(pool_container)

	_pools[p_pool_name] = {"scene": p_scene, "inactive": [], "container": pool_container}

	for i in range(p_initial_size):
		var instance: Node = p_scene.instantiate()
		instance.set_meta("pool_name", p_pool_name)
		pool_container.add_child(instance)
		if instance.has_method("deactivate"):
			instance.deactivate()
		_pools[p_pool_name].inactive.append(instance)
