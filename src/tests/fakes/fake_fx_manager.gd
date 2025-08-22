# src/tests/fakes/fake_fx_manager.gd
## A test-double (fake) implementation of the FXManager for use in unit tests.
## This is a "stub" that provides no-op implementations of the real methods.
class_name FakeFXManager
extends Node

func request_screen_shake(_shake_effect: ScreenShakeEffect) -> void:
	pass # No-op

func play_vfx(_effect: VFXEffect, _global_position: Vector2, _direction: Vector2 = Vector2.ZERO) -> void:
	pass # No-op

func play_shader(_effect: ShaderEffect, _target_node: Node, _options: Dictionary = {}) -> void:
	pass # No-op

func request_hit_stop(_duration: float) -> void:
	pass # No-op
