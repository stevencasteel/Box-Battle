# src/api/interfaces/IObjectPool.gd
## The "interface" contract for a system that manages pools of reusable nodes.
## This decouples systems from the concrete ObjectPool autoload, enabling
## substitution with fakes or mocks during testing.
class_name IObjectPool
extends Node

# --- Virtual Methods (The Contract) ---

## Retrieves an inactive instance from the specified pool.
func get_instance(_pool_name: StringName) -> Node:
	return null

## Returns an active instance to its pool.
func return_instance(_instance: Node) -> void:
	pass

## Returns all active instances in all pools to their inactive state.
func reset() -> void:
	pass

## Returns a dictionary containing the active/total counts for each pool.
func get_pool_stats() -> Dictionary:
	return {}