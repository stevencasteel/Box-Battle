# src/core/util/grid_utils.gd
# A singleton that provides a single source of truth for all calculations
# between the logical tile grid and world-space pixel coordinates.
extends Node

# Converts a grid coordinate (e.g., Vector2i(3, 4)) to the center
# of that tile in world pixels.
static func grid_to_world(tile_pos: Vector2i) -> Vector2:
	var half_tile = Constants.TILE_SIZE / 2.0
	return Vector2(tile_pos.x * Constants.TILE_SIZE + half_tile, tile_pos.y * Constants.TILE_SIZE + half_tile)

# Converts a world-space pixel position (e.g., from a mouse click)
# to the grid coordinate of the tile it is inside.
static func world_to_grid(world_pos: Vector2) -> Vector2i:
	return Vector2i(floor(world_pos.x / Constants.TILE_SIZE), floor(world_pos.y / Constants.TILE_SIZE))
