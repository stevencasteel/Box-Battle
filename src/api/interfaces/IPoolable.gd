# src/api/interfaces/IPoolable.gd
## The "interface" contract for any scene that can be managed by the [ObjectPool].
class_name IPoolable
extends Node

# --- The Contract ---

## Prepares the node for use after being retrieved from the pool.
func activate() -> void:
	pass

## Prepares the node to be returned to the pool's inactive list.
func deactivate() -> void:
	pass