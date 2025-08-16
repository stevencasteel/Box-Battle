# src/core/util/grid_utils.gd
## An autoloaded singleton providing a single source of truth for all conversions
## between the logical tile grid and world-space pixel coordinates.
extends Node

# --- Static Functions ---

## Converts a grid coordinate (e.g., [Vector2i(2, 3)]) to a world position.
static func grid_to_world(tile_pos: Vector2i, tile_size: int = Constants.TILE_SIZE) -> Vector2:
	var half_tile = tile_size / 2.0
	return Vector2(tile_pos.x * tile_size + half_tile, tile_pos.y * tile_size + half_tile)

## Converts a world position (in pixels) to its corresponding grid coordinate.
static func world_to_grid(world_pos: Vector2, tile_size: int = Constants.TILE_SIZE) -> Vector2i:
	return Vector2i(floor(world_pos.x / tile_size), floor(world_pos.y / tile_size))