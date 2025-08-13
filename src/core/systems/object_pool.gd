# src/core/systems/object_pool.gd
#
# This version is hardened against race conditions and now includes
# proper metadata on all projectile scenes for reliable pooling.
extends Node

const PlayerShotScene = preload(AssetPaths.SCENE_PLAYER_SHOT)
const BossShotScene = preload(AssetPaths.SCENE_BOSS_SHOT)
const TurretShotScene = preload(AssetPaths.SCENE_TURRET_SHOT)

var _pools: Dictionary = {}

func _ready():
	_create_pool_for_scene(&"player_shots", PlayerShotScene, 15)
	_create_pool_for_scene(&"boss_shots", BossShotScene, 30)
	_create_pool_for_scene(&"turret_shots", TurretShotScene, 20)

func reset():
	for pool_name in _pools:
		var pool = _pools[pool_name]
		for child in pool.container.get_children():
			if not pool.inactive.has(child):
				return_instance(child)

func _create_pool_for_scene(p_pool_name: StringName, p_scene: PackedScene, p_initial_size: int):
	if _pools.has(p_pool_name):
		return
		
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

func get_instance(p_pool_name: StringName) -> Node:
	if not _pools.has(p_pool_name):
		push_error("ObjectPool: Pool '%s' does not exist." % p_pool_name)
		return null

	var pool = _pools[p_pool_name]
	var instance: Node
	
	if not pool.inactive.is_empty():
		instance = pool.inactive.pop_front()
	else:
		instance = pool.scene.instantiate()
		pool.container.add_child(instance)
	
	return instance

func return_instance(p_instance: Node):
	if not is_instance_valid(p_instance) or p_instance.process_mode == PROCESS_MODE_DISABLED:
		return

	var pool_name = p_instance.get_meta("pool_name", "")
	if pool_name == "" or not _pools.has(pool_name):
		p_instance.queue_free()
		return
	
	p_instance.call_deferred("deactivate")
	
	if not _pools[pool_name].inactive.has(p_instance):
		_pools[pool_name].inactive.append(p_instance)
		# THE FIX: Use a more descriptive print statement.
		print("VERIFICATION: Returned '%s' to pool '%s'. Deactivation is deferred." % [p_instance.name, pool_name])