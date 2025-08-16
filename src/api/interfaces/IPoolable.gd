# src/api/interfaces/IPoolable.gd
## The conceptual "interface" for any scene that can be managed by the [ObjectPool].
##
## This script is not meant to be extended directly. It serves as project
## documentation. A scene is considered "poolable" if it implements the methods
## defined in this contract.
class_name IPoolable

# --- The Contract ---

## Prepares the node for use after being retrieved from the pool.
##
## This method should handle logic like enabling processing, making collision
## shapes active, and resetting any state from its previous use.
# func activate() -> void:
#     pass

## Prepares the node to be returned to the pool's inactive list.
##
## This method should handle logic like disabling processing, hiding the node,
## disabling collision shapes, and moving it to an off-screen "graveyard" position.
# func deactivate() -> void:
#     pass