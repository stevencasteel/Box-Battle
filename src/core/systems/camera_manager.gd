# src/core/systems/camera_manager.gd
# A singleton responsible for all camera logic, including fitting the
# camera to the arena to support different aspect ratios.
extends Node

# This function calculates the correct zoom and position to make the
# entire arena visible within the camera's viewport.
func fit_camera_to_arena(camera: Camera2D, arena_size_tiles: Vector2i):
	if not is_instance_valid(camera):
		push_error("CameraManager: Invalid Camera2D provided.")
		return

	# Calculate the arena's total size in world pixels.
	var arena_pixel_size = Vector2(arena_size_tiles) * Constants.TILE_SIZE
	
	# Get the size of the viewport the camera is rendering to.
	var screen_size = camera.get_viewport_rect().size
	if screen_size.x == 0 or screen_size.y == 0:
		return # Avoid division by zero if the viewport isn't ready.

	# Calculate the required zoom to fit the arena's width and height.
	var zoom_x = arena_pixel_size.x / screen_size.x
	var zoom_y = arena_pixel_size.y / screen_size.y
	
	# Use the larger of the two zoom values to ensure the whole arena is visible.
	var zoom_level = max(zoom_x, zoom_y)
	
	camera.zoom = Vector2(zoom_level, zoom_level)
	
	# Position the camera in the center of the arena.
	camera.position = arena_pixel_size / 2.0
	
	print("VERIFICATION: Camera fitted. New zoom: ", camera.zoom)
