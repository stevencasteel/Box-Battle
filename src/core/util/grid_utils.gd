# src/core/util/grid_utils.gd
# A singleton that provides a single source of truth for all calculations
# between the logical tile grid and world-space pixel coordinates.
extends Node

# THE FIX: The function now accepts tile_size as a parameter, removing
# its dependency on the Constants autoload. This makes it safe to use
# from any @tool script.
static func grid_to_world(tile_pos: Vector2i, tile_size: int = Constants.TILE_SIZE) -> Vector2:
	var half_tile = tile_size / 2.0
	return Vector2(tile_pos.x * tile_size + half_tile, tile_pos.y * tile_size + half_tile)

static func world_to_grid(world_pos: Vector2, tile_size: int = Constants.TILE_SIZE) -> Vector2i:
	return Vector2i(floor(world_pos.x / tile_size), floor(world_pos.y / tile_size))