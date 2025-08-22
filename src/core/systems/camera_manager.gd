# src/core/systems/camera_manager.gd
## An autoloaded singleton responsible for all camera logic.
extends Node

# --- Public Methods ---


## Centers the camera on the arena for a pixel-perfect setup.
func center_camera_on_arena(camera: Camera2D, arena_size_tiles: Vector2i) -> void:
	if not is_instance_valid(camera):
		push_error("CameraManager: Invalid Camera2D provided.")
		return

	var arena_pixel_size = Vector2(arena_size_tiles) * Constants.TILE_SIZE
	camera.position = arena_pixel_size / 2.0
