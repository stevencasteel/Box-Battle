# src/api/interfaces/IFXManager.gd
## The "interface" contract for a system that manages visual and feedback effects.
## This script defines the public API, abstracting components from the concrete
## implementation (e.g., the global FXManager autoload).
class_name IFXManager
extends Node

# --- Virtual Methods (The Contract) ---

func register_camera_shaker(_shaker: CameraShaker) -> void: pass
func unregister_camera_shaker() -> void: pass
func is_camera_shaker_registered() -> bool: return false
func request_screen_shake(_shake_effect: ScreenShakeEffect) -> void: pass
func play_vfx(_effect: VFXEffect, _global_position: Vector2, _direction: Vector2 = Vector2.ZERO) -> void: pass
func request_hit_stop(_duration: float) -> void: pass
func prewarm_shaders_async(_effects: Array[ShaderEffect], _prewarm_viewport: SubViewport) -> void: pass
func get_debug_stats() -> Dictionary: return {}
func increment_shader_count() -> void: pass
func decrement_shader_count() -> void: pass
