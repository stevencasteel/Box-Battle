# src/core/systems/camera_manager.gd
# A singleton responsible for all camera logic. It now focuses on
# centering the camera for our pixel-perfect setup.
extends Node

# This function now simply centers the camera on the arena.
# The zoom is assumed to be (1, 1) for pixel-perfect rendering.
func center_camera_on_arena(camera: Camera2D, arena_size_tiles: Vector2i):
	if not is_instance_valid(camera):
		push_error("CameraManager: Invalid Camera2D provided.")
		return

	var arena_pixel_size = Vector2(arena_size_tiles) * Constants.TILE_SIZE
	
	# The position is the exact center. The engine's pixel snap will handle the rest.
	camera.position = arena_pixel_size / 2.0
	
	print("VERIFICATION: Camera centered on arena.")