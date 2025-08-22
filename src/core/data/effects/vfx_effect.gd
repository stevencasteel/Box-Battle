# src/core/data/effects/vfx_effect.gd
@tool
## A data resource that defines a "recipe" for a visual effect.
##
## It tells the FXManager which scene to retrieve from which ObjectPool.
## This allows for the creation of reusable, data-driven visual effects.
class_name VFXEffect
extends Resource

## The PackedScene of the visual effect to be instanced from the pool.
@export var scene: PackedScene

## The StringName key for the ObjectPool where this VFX scene is stored.
@export var pool_key: StringName = &""
