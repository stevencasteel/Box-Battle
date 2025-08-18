# src/tests/unit/test_object_pool.gd
extends GutTest

var object_pool: ObjectPool
const POOL_KEY = Identifiers.Pools.PLAYER_SHOTS

func before_each():
	object_pool = get_node("/root/ObjectPool")
	object_pool.reset()
	await get_tree().process_frame

func test_get_instance_returns_valid_node_and_can_be_activated():
	var instance = object_pool.get_instance(POOL_KEY)
	assert_not_null(instance, "get_instance should return a valid node.")
	assert_true(instance is Node, "Instance should be a Node.")
	assert_eq(instance.process_mode, PROCESS_MODE_INHERIT, "get_instance should activate the node.")

# THE FIX: This test must now be async to handle the deferred call.
func test_return_instance_makes_it_inactive() -> void:
	var instance = object_pool.get_instance(POOL_KEY)
	object_pool.return_instance(instance)
	
	# Wait for the next frame for the deferred call to 'deactivate' to execute.
	await get_tree().process_frame
	
	assert_eq(instance.process_mode, PROCESS_MODE_DISABLED, "return_instance should deactivate the node after one frame.")

func test_pool_reuses_returned_instances() -> void:
	var first_instance = object_pool.get_instance(POOL_KEY)
	var first_instance_id = first_instance.get_instance_id()
	
	object_pool.return_instance(first_instance)
	
	# The instance is now available again on the next frame.
	await get_tree().process_frame
	
	var second_instance = object_pool.get_instance(POOL_KEY)
	var second_instance_id = second_instance.get_instance_id()
	
	assert_eq(first_instance_id, second_instance_id, "The pool should return the same instance that was just returned to it.")

func test_reset_returns_all_active_instances() -> void:
	var instance1 = object_pool.get_instance(POOL_KEY)
	var instance2 = object_pool.get_instance(POOL_KEY)
	var instance3 = object_pool.get_instance(POOL_KEY)
	
	var stats_before = object_pool.get_pool_stats()
	assert_eq(stats_before[POOL_KEY].active, 3, "There should be 3 active instances before reset.")
	
	object_pool.reset()
	await get_tree().process_frame
	
	var stats_after = object_pool.get_pool_stats()
	assert_eq(stats_after[POOL_KEY].active, 0, "There should be 0 active instances after reset.")