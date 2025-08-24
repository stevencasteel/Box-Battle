# src/api/interfaces/IPoolable.gd
## The "interface" contract for any scene that can be managed by the [ObjectPool].
class_name IPoolable
extends Node

# --- The Contract ---


## Prepares the node for use after being retrieved from the pool.
## Receives a dictionary of dependencies, which should include the ServiceLocator.
func activate(_dependencies: Dictionary = {}) -> void:
	pass


## Prepares the node to be returned to the pool's inactive list.
##
## CONTRACT: Any implementation of this method MUST release all external
## references it holds, especially references to services obtained from the
## ServiceLocator. This is critical for preventing memory leaks and crashes
## during scene transitions.
func deactivate() -> void:
	pass
