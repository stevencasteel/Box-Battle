# src/tests/fakes/fake_object_pool.gd
## A test-double (fake) implementation of the ObjectPool for use in unit tests.
class_name FakeObjectPool
extends Node

# --- Constants ---
const FakeProjectile = preload("res://src/tests/fakes/fake_projectile.gd")

# --- Private Member Variables ---
var _get_counts: Dictionary = {}
var _return_counts: Dictionary = {}

func get_instance(p_pool_name: StringName) -> Node:
	_get_counts[p_pool_name] = _get_counts.get(p_pool_name, 0) + 1
	
	# THE FIX: Return an instance of FakeProjectile to satisfy the API contract.
	var fake_instance = FakeProjectile.new()
	fake_instance.name = "FakePooledInstance"
	fake_instance.set_meta("pool_name", p_pool_name)
	add_child(fake_instance)
	return fake_instance

func return_instance(p_instance: Node) -> void:
	if not is_instance_valid(p_instance): return
	
	var pool_name = p_instance.get_meta("pool_name", &"unknown")
	_return_counts[pool_name] = _return_counts.get(pool_name, 0) + 1
	p_instance.queue_free()

## Clears all recorded call counts.
func clear() -> void:
	_get_counts.clear()
	_return_counts.clear()

## Returns the number of times get_instance was called for a specific pool.
func get_call_count(pool_name: StringName) -> int:
	return _get_counts.get(pool_name, 0)

## Returns the number of times return_instance was called for a specific pool.
func get_return_count(pool_name: StringName) -> int:
	return _return_counts.get(pool_name, 0)