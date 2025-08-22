# src/tests/fakes/fake_projectile.gd
## A lightweight fake projectile for use in unit tests.
## Mimics the necessary API of real projectiles for the ObjectPool.
class_name FakeProjectile
extends Node2D  # THE FIX: Extend Node2D to get transform properties like global_position.

var direction: Vector2
var _object_pool: Node


func activate(p_dependencies: Dictionary = {}) -> void:
	self._object_pool = p_dependencies.get("object_pool")


func deactivate() -> void:
	self._object_pool = null
