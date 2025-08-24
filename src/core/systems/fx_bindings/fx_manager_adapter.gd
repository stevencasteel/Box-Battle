# src/core/systems/fx_bindings/fx_manager_adapter.gd
## An adapter that implements the IFXManager interface by delegating calls
## to the real FXManager autoload singleton. This decouples our components
## from the global scope, enabling easier testing and substitution.
class_name FXManagerAdapter
extends IFXManager

# --- Private Member Variables ---
var _real_fx_manager: Node

# --- Godot Lifecycle Methods ---
func _ready() -> void:
	# Find the actual autoloaded singleton in the scene tree.
	_real_fx_manager = get_node("/root/FXManager")
	assert(is_instance_valid(_real_fx_manager), "FXManagerAdapter could not find /root/FXManager")

# --- IFXManager Implementation ---

func register_camera_shaker(shaker: CameraShaker) -> void:
	_real_fx_manager.register_camera_shaker(shaker)

func unregister_camera_shaker() -> void:
	_real_fx_manager.unregister_camera_shaker()

func is_camera_shaker_registered() -> bool:
	return _real_fx_manager.is_camera_shaker_registered()

func request_screen_shake(shake_effect: ScreenShakeEffect) -> void:
	_real_fx_manager.request_screen_shake(shake_effect)

func play_vfx(effect: VFXEffect, global_position: Vector2, direction: Vector2 = Vector2.ZERO) -> void:
	_real_fx_manager.play_vfx(effect, global_position, direction)

func request_hit_stop(duration: float) -> void:
	_real_fx_manager.request_hit_stop(duration)

func prewarm_shaders_async(effects: Array[ShaderEffect], prewarm_viewport: SubViewport) -> void:
	# This is an awaitable function, so we must await it.
	await _real_fx_manager.prewarm_shaders_async(effects, prewarm_viewport)

func get_debug_stats() -> Dictionary:
	return _real_fx_manager.get_debug_stats()

func increment_shader_count() -> void:
	_real_fx_manager.increment_shader_count()

func decrement_shader_count() -> void:
	_real_fx_manager.decrement_shader_count()
