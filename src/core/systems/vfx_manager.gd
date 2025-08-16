# src/core/systems/vfx_manager.gd
## An autoloaded singleton for spawning and managing visual effects (VFX).
##
## This system will interact with the [ObjectPool] to efficiently create and
## destroy short-lived visual effects like particle systems.
extends Node

# TODO: Add methods to spawn specific, named particle effects from a pool.
# Example: func play_hit_spark(p_position: Vector2) -> void:

# TODO: Add methods for controlling screen-wide shader effects.
# Example: func start_vignette_pulse() -> void:

func _ready() -> void:
	pass