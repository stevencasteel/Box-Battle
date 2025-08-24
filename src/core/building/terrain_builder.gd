# src/core/building/terrain_builder.gd
@tool
## Responsible for creating all static level geometry nodes.
##
## This includes solid walls, one-way platforms, hazards, and background tiles.
## It uses [Polygon2D] for in-game visuals to prevent conflicts with debug drawing.
class_name TerrainBuilder
extends Node

# --- Public Methods ---


## Asynchronously creates all terrain nodes defined in the [LevelBuildData].
func build_terrain_async(
	parent_node: Node, build_data: LevelBuildData, tree: SceneTree, services: ServiceLocator
) -> void:
	const BATCH_SIZE = 20

	for i in range(build_data.terrain_tiles.size()):
		_create_solid_tile(parent_node, build_data.terrain_tiles[i], services)
		if i % BATCH_SIZE == 0:
			await tree.process_frame

	for i in range(build_data.oneway_platforms.size()):
		_create_oneway_platform(parent_node, build_data.oneway_platforms[i], services)
		if i % BATCH_SIZE == 0:
			await tree.process_frame

	for i in range(build_data.hazard_tiles.size()):
		_create_hazard_tile(parent_node, build_data.hazard_tiles[i], services)
		if i % BATCH_SIZE == 0:
			await tree.process_frame

	await tree.process_frame


## Procedurally fills the camera's viewport with background grid tiles.
func fill_viewport(
	parent_node: Node, build_data: LevelBuildData, camera: Camera2D, services: ServiceLocator
) -> void:
	var view_transform = camera.get_viewport().get_canvas_transform().affine_inverse()
	var world_top_left = view_transform.origin
	var world_bottom_right = (
		world_top_left + camera.get_viewport_rect().size * view_transform.get_scale()
	)

	var grid_top_left: Vector2i = services.grid_utils.world_to_grid(world_top_left)
	var grid_bottom_right: Vector2i = services.grid_utils.world_to_grid(world_bottom_right)

	var existing_bg_tiles = {}
	for pos in build_data.background_tiles:
		existing_bg_tiles[pos] = true

	for y in range(grid_top_left.y, grid_bottom_right.y + 1):
		for x in range(grid_top_left.x, grid_bottom_right.x + 1):
			var grid_pos = Vector2i(x, y)
			if not existing_bg_tiles.has(grid_pos):
				_create_background_tile(parent_node, grid_pos)


# --- Private Methods ---


func _create_background_tile(parent_node: Node, grid_pos: Vector2i) -> void:
	var visual_rect = ColorRect.new()
	visual_rect.color = Palette.COLOR_GRID
	visual_rect.size = Vector2(Constants.TILE_SIZE, Constants.TILE_SIZE)
	visual_rect.position = Vector2(grid_pos) * Constants.TILE_SIZE
	parent_node.add_child(visual_rect)
	parent_node.move_child(visual_rect, 0)


func _create_solid_tile(parent_node: Node, pos: Vector2, _services: ServiceLocator) -> void:
	var static_body := StaticBody2D.new()
	static_body.position = pos
	static_body.collision_layer = PhysicsLayers.SOLID_WORLD
	static_body.add_to_group(Identifiers.Groups.WORLD)

	var collision_shape := CollisionShape2D.new()
	var rectangle_shape := RectangleShape2D.new()
	rectangle_shape.size = Vector2(Constants.TILE_SIZE, Constants.TILE_SIZE)
	collision_shape.shape = rectangle_shape
	static_body.add_child(collision_shape)

	var visual_poly := Polygon2D.new()
	var half_size = Constants.TILE_SIZE / 2.0
	visual_poly.polygon = PackedVector2Array(
		[
			Vector2(-half_size, -half_size),
			Vector2(half_size, -half_size),
			Vector2(half_size, half_size),
			Vector2(-half_size, half_size)
		]
	)
	visual_poly.color = Palette.COLOR_TERRAIN_PRIMARY
	static_body.add_child(visual_poly)

	parent_node.add_child(static_body)


func _create_oneway_platform(parent_node: Node, pos: Vector2, _services: ServiceLocator) -> void:
	var static_body := StaticBody2D.new()
	static_body.position = pos
	static_body.collision_layer = PhysicsLayers.PLATFORMS
	static_body.add_to_group(Identifiers.Groups.WORLD)
	static_body.add_to_group(Identifiers.Groups.ONEWAY_PLATFORMS)

	var collision_shape := CollisionShape2D.new()
	collision_shape.one_way_collision = true
	var rectangle_shape := RectangleShape2D.new()
	var platform_height = 10.0
	rectangle_shape.size = Vector2(Constants.TILE_SIZE, platform_height)
	collision_shape.shape = rectangle_shape
	collision_shape.position.y = -(Constants.TILE_SIZE / 2.0) + (rectangle_shape.size.y / 2.0)
	static_body.add_child(collision_shape)

	var visual_poly := Polygon2D.new()
	var half_width = Constants.TILE_SIZE / 2.0
	var half_height = platform_height / 2.0
	visual_poly.position = collision_shape.position
	visual_poly.polygon = PackedVector2Array(
		[
			Vector2(-half_width, -half_height),
			Vector2(half_width, -half_height),
			Vector2(half_width, half_height),
			Vector2(-half_width, half_height)
		]
	)
	visual_poly.color = Palette.COLOR_TERRAIN_SECONDARY
	static_body.add_child(visual_poly)

	parent_node.add_child(static_body)


func _create_hazard_tile(parent_node: Node, pos: Vector2, _services: ServiceLocator) -> void:
	var static_body := StaticBody2D.new()
	static_body.position = pos
	static_body.collision_layer = PhysicsLayers.HAZARD | PhysicsLayers.SOLID_WORLD
	static_body.add_to_group(Identifiers.Groups.WORLD)
	static_body.add_to_group(Identifiers.Groups.HAZARD)

	var collision_shape := CollisionShape2D.new()
	var rectangle_shape := RectangleShape2D.new()
	rectangle_shape.size = Vector2(Constants.TILE_SIZE, Constants.TILE_SIZE)
	collision_shape.shape = rectangle_shape
	static_body.add_child(collision_shape)

	var visual_poly := Polygon2D.new()
	var half_size = Constants.TILE_SIZE / 2.0
	visual_poly.polygon = PackedVector2Array(
		[
			Vector2(-half_size, -half_size),
			Vector2(half_size, -half_size),
			Vector2(half_size, half_size),
			Vector2(-half_size, half_size)
		]
	)
	visual_poly.color = Palette.COLOR_HAZARD_PRIMARY
	static_body.add_child(visual_poly)

	parent_node.add_child(static_body)
