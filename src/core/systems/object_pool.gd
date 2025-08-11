# src/core/systems/object_pool.gd
#
# This version has been hardened to remove fragile name-based lookups. It now
# stores a direct reference to the container node for each pool, making it
# immune to errors from renaming nodes.
extends Node

const PlayerShotScene = preload(AssetPaths.SCENE_PLAYER_SHOT)
const BossShotScene = preload(AssetPaths.SCENE_BOSS_SHOT)

var _pools: Dictionary = {}

func _ready():
	_create_pool_for_scene(&"player_shots", PlayerShotScene, 15)
	_create_pool_for_scene(&"boss_shots", BossShotScene, 30)

func _create_pool_for_scene(p_pool_name: StringName, p_scene: PackedScene, p_initial_size: int):
	if _pools.has(p_pool_name):
		return
		
	var pool_container = Node.new()
	pool_container.name = p_pool_name
	add_child(pool_container)
	
	# MODIFIED: The pool's data now includes a direct reference to its container node.
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

func get_instance(p_pool_name: StringName) -> Node:
	if not _pools.has(p_pool_name):
		push_error("ObjectPool: Pool '%s' does not exist." % p_pool_name)
		return null

	var pool = _pools[p_pool_name]
	var instance: Node
	
	if not pool.inactive.is_empty():
		instance = pool.inactive.pop_front()
	else:
		# This case handles if the pool runs dry during intense combat.
		instance = pool.scene.instantiate()
		# MODIFIED: We now use the direct reference to the container, which is robust.
		pool.container.add_child(instance)
	
	return instance

func return_instance(p_instance: Node):
	if not is_instance_valid(p_instance) or p_instance.process_mode == PROCESS_MODE_DISABLED:
		return

	var pool_name = p_instance.get_meta("pool_name", "")
	if pool_name == "" or not _pools.has(pool_name):
		# It's safer to just queue_free() than to assume ownership.
		p_instance.queue_free()
		return
	
	p_instance.deactivate()
	_pools[pool_name].inactive.append(p_instance)