# src/core/systems/object_pool.gd
## An autoloaded singleton that manages pools of reusable nodes.
##
## This system prevents performance degradation (stutter) from frequent
## instantiation and deletion of nodes like projectiles and visual effects.
extends Node

# --- Constants ---
const PlayerShotScene = preload(AssetPaths.SCENE_PLAYER_SHOT)
const BossShotScene = preload(AssetPaths.SCENE_BOSS_SHOT)
const TurretShotScene = preload(AssetPaths.SCENE_TURRET_SHOT)

# --- Private Member Variables ---
var _pools: Dictionary = {}

# --- Godot Lifecycle Methods ---

func _ready() -> void:
	_create_pool_for_scene(Identifiers.Pools.PLAYER_SHOTS, PlayerShotScene, 15)
	_create_pool_for_scene(Identifiers.Pools.BOSS_SHOTS, BossShotScene, 30)
	_create_pool_for_scene(Identifiers.Pools.TURRET_SHOTS, TurretShotScene, 20)

# --- Public Methods ---

## Returns a dictionary containing the active/total counts for each pool.
func get_pool_stats() -> Dictionary:
	var stats: Dictionary = {}
	for pool_name in _pools:
		var pool = _pools[pool_name]
		var total_count = pool.container.get_child_count()
		var inactive_count = pool.inactive.size()
		stats[pool_name] = {
			"active": total_count - inactive_count,
			"total": total_count
		}
	return stats

## Returns all active instances in all pools to their inactive state.
func reset() -> void:
	for pool_name in _pools:
		var pool = _pools[pool_name]
		var active_nodes_to_return: Array[Node] = []
		for child in pool.container.get_children():
			if not pool.inactive.has(child):
				active_nodes_to_return.append(child)
		
		for node in active_nodes_to_return:
			return_instance(node)

## Retrieves an inactive instance from the specified pool.
func get_instance(p_pool_name: StringName) -> Node:
	if not _pools.has(p_pool_name):
		push_error("ObjectPool: Pool '%s' does not exist." % p_pool_name)
		return null

	var pool = _pools[p_pool_name]
	var instance: Node

	if not pool.inactive.is_empty():
		instance = pool.inactive.pop_front()
	else: # Pool is empty, create a new instance
		instance = pool.scene.instantiate()
		pool.container.add_child(instance)

	if instance.has_method("activate"):
		instance.activate()

	return instance

## Returns an active instance to its pool.
func return_instance(p_instance: Node) -> void:
	if not is_instance_valid(p_instance) or p_instance.process_mode == PROCESS_MODE_DISABLED:
		return

	var pool_name = p_instance.get_meta("pool_name", "")
	if pool_name == "" or not _pools.has(pool_name):
		p_instance.queue_free()
		return

	if p_instance.has_method("deactivate"):
		p_instance.call_deferred("deactivate")

	# THE FIX: Use the correct variable 'pool_name' instead of 'p_pool_name'.
	if not _pools[pool_name].inactive.has(p_instance):
		_pools[pool_name].inactive.push_front(p_instance)

# --- Private Methods ---

func _create_pool_for_scene(p_pool_name: StringName, p_scene: PackedScene, p_initial_size: int) -> void:
	if _pools.has(p_pool_name): return

	var pool_container = Node.new()
	pool_container.name = p_pool_name
	add_child(pool_container)

	_pools[p_pool_name] = {
		"scene": p_scene,
		"inactive": [],
		"container": pool_container
	}

	for i in range(p_initial_size):
		var instance = p_scene.instantiate()
		pool_container.add_child(instance)
		instance.deactivate()
		_pools[p_pool_name].inactive.append(instance)