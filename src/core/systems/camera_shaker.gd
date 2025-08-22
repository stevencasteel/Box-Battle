# src/core/systems/camera_shaker.gd
## A self-contained component that applies a procedural shake to a target Camera2D.
##
## It uses Perlin noise to generate a smooth, decaying shake effect by manipulating
## the target camera's `offset` property.
class_name CameraShaker
extends Node

# --- Public Member Variables ---
## A reference to the Camera2D node this shaker will control.
var target_camera: Camera2D = null

# --- Private Member Variables ---
var _noise := FastNoiseLite.new()
var _noise_y_offset: float = 0.0  # Use a different seed for the y-axis
var _shake_duration: float = 0.0
var _shake_timer: float = 0.0
var _shake_amplitude: float = 0.0
var _shake_frequency: float = 0.0

# --- Godot Lifecycle Methods ---


func _ready() -> void:
	_noise.noise_type = FastNoiseLite.TYPE_PERLIN
	_noise.seed = randi()
	_noise_y_offset = randf() * 1000.0


func _process(delta: float) -> void:
	if not is_instance_valid(target_camera):
		return

	if _shake_timer > 0:
		_shake_timer -= delta
		if _shake_timer <= 0:
			target_camera.offset = Vector2.ZERO
		else:
			var decay_progress: float = 1.0 - (_shake_timer / _shake_duration)
			var current_amplitude: float = _shake_amplitude * (1.0 - decay_progress)

			var time: float = Time.get_ticks_msec() * (_shake_frequency / 1000.0)
			var noise_x: float = _noise.get_noise_2d(time, 0)
			var noise_y: float = _noise.get_noise_2d(time, _noise_y_offset)

			target_camera.offset.x = noise_x * current_amplitude
			target_camera.offset.y = noise_y * current_amplitude
	else:
		target_camera.offset = Vector2.ZERO


# --- Public API ---


func start_shake(effect: ScreenShakeEffect) -> void:
	if not is_instance_valid(effect):
		push_error("CameraShaker: Invalid ScreenShakeEffect resource provided.")
		return

	_shake_amplitude = effect.amplitude
	_shake_frequency = effect.frequency
	_shake_duration = effect.duration
	_shake_timer = _shake_duration
