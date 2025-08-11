# src/core/builders/terrain_builder.gd
#
# Responsibility: To create all static level geometry. It now uses a robust
# transform-based calculation to correctly fill the entire viewport.
class_name TerrainBuilder
extends RefCounted

const GridUtilsScript = preload("res://src/core/util/grid_utils.gd")

func build_terrain_async(parent_node: Node, build_data: LevelBuildData, tree: SceneTree) -> void:
	const BATCH_SIZE = 20

	for i in range(build_data.terrain_tiles.size()):
		_create_solid_tile(parent_node, build_data.terrain_tiles[i])
		if i % BATCH_SIZE == 0: await tree.process_frame

	for i in range(build_data.oneway_platforms.size()):
		_create_oneway_platform(parent_node, build_data.oneway_platforms[i])
		if i % BATCH_SIZE == 0: await tree.process_frame

	for i in range(build_data.hazard_tiles.size()):
		_create_hazard_tile(parent_node, build_data.hazard_tiles[i])
		if i % BATCH_SIZE == 0: await tree.process_frame
	
	await tree.process_frame

func fill_viewport(parent_node: Node, build_data: LevelBuildData, camera: Camera2D):
	# THE FIX: This is the robust way to get the camera's world view.
	# It asks the engine for the transform that converts screen points to world points.
	var view_transform = camera.get_viewport().get_canvas_transform().affine_inverse()
	var world_top_left = view_transform.origin
	var world_bottom_right = world_top_left + camera.get_viewport_rect().size * view_transform.get_scale()
	
	var grid_top_left = GridUtilsScript.world_to_grid(world_top_left)
	var grid_bottom_right = GridUtilsScript.world_to_grid(world_bottom_right)
	
	var existing_bg_tiles = {}
	for pos in build_data.background_tiles:
		existing_bg_tiles[pos] = true

	for y in range(grid_top_left.y, grid_bottom_right.y + 1):
		for x in range(grid_top_left.x, grid_bottom_right.x + 1):
			var grid_pos = Vector2i(x, y)
			if not existing_bg_tiles.has(grid_pos):
				_create_background_tile(parent_node, grid_pos)

func _create_background_tile(parent_node: Node, grid_pos: Vector2i):
	var visual_rect = ColorRect.new()
	visual_rect.color = Palette.COLOR_GRID
	visual_rect.size = Vector2(Constants.TILE_SIZE, Constants.TILE_SIZE)
	visual_rect.position = Vector2(grid_pos) * Constants.TILE_SIZE
	parent_node.add_child(visual_rect)
	parent_node.move_child(visual_rect, 0)

func _create_solid_tile(parent_node: Node, pos: Vector2) -> void:
	var static_body := StaticBody2D.new()
	static_body.position = pos
	static_body.collision_layer = 2
	static_body.add_to_group("world")
	
	var collision_shape := CollisionShape2D.new()
	var rectangle_shape := RectangleShape2D.new()
	rectangle_shape.size = Vector2(Constants.TILE_SIZE, Constants.TILE_SIZE)
	collision_shape.shape = rectangle_shape
	static_body.add_child(collision_shape)
	
	var visual_rect := ColorRect.new()
	visual_rect.color = Palette.COLOR_TERRAIN_PRIMARY
	visual_rect.size = rectangle_shape.size
	visual_rect.position = -rectangle_shape.size / 2.0
	static_body.add_child(visual_rect)
	
	parent_node.add_child(static_body)

func _create_oneway_platform(parent_node: Node, pos: Vector2) -> void:
	var static_body := StaticBody2D.new()
	static_body.position = pos
	static_body.collision_layer = 2
	static_body.add_to_group("world")
	static_body.add_to_group("oneway_platforms")
	
	var collision_shape := CollisionShape2D.new()
	collision_shape.one_way_collision = true
	var rectangle_shape := RectangleShape2D.new()
	rectangle_shape.size = Vector2(Constants.TILE_SIZE, 10)
	collision_shape.shape = rectangle_shape
	collision_shape.position.y = -(Constants.TILE_SIZE / 2.0) + (rectangle_shape.size.y / 2.0)
	static_body.add_child(collision_shape)

	var visual_rect := ColorRect.new()
	visual_rect.color = Palette.COLOR_TERRAIN_SECONDARY
	visual_rect.size = rectangle_shape.size
	visual_rect.position = Vector2(-rectangle_shape.size.x / 2.0, collision_shape.position.y - (rectangle_shape.size.y / 2.0))
	static_body.add_child(visual_rect)
	
	parent_node.add_child(static_body)

func _create_hazard_tile(parent_node: Node, pos: Vector2) -> void:
	var static_body := StaticBody2D.new()
	static_body.position = pos
	static_body.collision_layer = 10
	static_body.add_to_group("world")
	static_body.add_to_group("hazard")
	
	var collision_shape := CollisionShape2D.new()
	var rectangle_shape := RectangleShape2D.new()
	rectangle_shape.size = Vector2(Constants.TILE_SIZE, Constants.TILE_SIZE)
	collision_shape.shape = rectangle_shape
	static_body.add_child(collision_shape)
	
	var visual_rect := ColorRect.new()
	visual_rect.color = Palette.COLOR_HAZARD_PRIMARY
	visual_rect.size = rectangle_shape.size
	visual_rect.position = -rectangle_shape.size / 2.0
	static_body.add_child(visual_rect)
	
	parent_node.add_child(static_body)