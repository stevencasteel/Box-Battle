# src/core/builders/terrain_builder.gd
#
# Responsibility: To create all static level geometry (solid tiles,
# one-way platforms, hazards) based on parsed LevelBuildData. It now also
# creates the visual representation for each tile using the Palette.
class_name TerrainBuilder
extends RefCounted

# The main public method. It takes the parent node, the data, and a valid
# SceneTree reference, then builds the tiles asynchronously in batches.
func build_terrain_async(parent_node: Node, build_data: LevelBuildData, tree: SceneTree) -> void:
	const BATCH_SIZE = 20 # How many tiles to create before yielding a frame.

	for i in range(build_data.terrain_tiles.size()):
		_create_solid_tile(parent_node, build_data.terrain_tiles[i])
		if i % BATCH_SIZE == 0:
			await tree.process_frame

	for i in range(build_data.oneway_platforms.size()):
		_create_oneway_platform(parent_node, build_data.oneway_platforms[i])
		if i % BATCH_SIZE == 0:
			await tree.process_frame

	for i in range(build_data.hazard_tiles.size()):
		_create_hazard_tile(parent_node, build_data.hazard_tiles[i])
		if i % BATCH_SIZE == 0:
			await tree.process_frame
	
	await tree.process_frame

# --- Tile Creation Functions (Now with Visuals) ---

func _create_solid_tile(parent_node: Node, pos: Vector2) -> void:
	var static_body := StaticBody2D.new()
	static_body.position = pos
	static_body.collision_layer = 2 # 'world' layer
	static_body.add_to_group("world")
	
	var collision_shape := CollisionShape2D.new()
	var rectangle_shape := RectangleShape2D.new()
	rectangle_shape.size = Vector2(Constants.TILE_SIZE, Constants.TILE_SIZE)
	collision_shape.shape = rectangle_shape
	static_body.add_child(collision_shape)
	
	# PALETTE INTEGRATION: Add a visible ColorRect.
	var visual_rect := ColorRect.new()
	visual_rect.color = Palette.COLOR_TERRAIN_PRIMARY
	visual_rect.size = rectangle_shape.size
	visual_rect.position = -rectangle_shape.size / 2.0 # Center the rect on the body's origin
	static_body.add_child(visual_rect)
	
	parent_node.add_child(static_body)

func _create_oneway_platform(parent_node: Node, pos: Vector2) -> void:
	var static_body := StaticBody2D.new()
	static_body.position = pos
	static_body.collision_layer = 2 # 'world' layer
	static_body.add_to_group("world")
	static_body.add_to_group("oneway_platforms")
	
	var collision_shape := CollisionShape2D.new()
	collision_shape.one_way_collision = true
	var rectangle_shape := RectangleShape2D.new()
	rectangle_shape.size = Vector2(Constants.TILE_SIZE, 10)
	collision_shape.shape = rectangle_shape
	collision_shape.position.y = -(Constants.TILE_SIZE / 2.0) + (rectangle_shape.size.y / 2.0)
	static_body.add_child(collision_shape)

	# PALETTE INTEGRATION: Add a visible ColorRect that matches the thin platform.
	var visual_rect := ColorRect.new()
	visual_rect.color = Palette.COLOR_TERRAIN_SECONDARY
	visual_rect.size = rectangle_shape.size
	visual_rect.position = Vector2(-rectangle_shape.size.x / 2.0, collision_shape.position.y - (rectangle_shape.size.y / 2.0))
	static_body.add_child(visual_rect)
	
	parent_node.add_child(static_body)

func _create_hazard_tile(parent_node: Node, pos: Vector2) -> void:
	var static_body := StaticBody2D.new()
	static_body.position = pos
	static_body.collision_layer = 10 # world | hazard
	static_body.add_to_group("world")
	static_body.add_to_group("hazard")
	
	var collision_shape := CollisionShape2D.new()
	var rectangle_shape := RectangleShape2D.new()
	rectangle_shape.size = Vector2(Constants.TILE_SIZE, Constants.TILE_SIZE)
	collision_shape.shape = rectangle_shape
	static_body.add_child(collision_shape)
	
	# PALETTE INTEGRATION: Add a visible ColorRect using the hazard color.
	var visual_rect := ColorRect.new()
	visual_rect.color = Palette.COLOR_HAZARD_PRIMARY
	visual_rect.size = rectangle_shape.size
	visual_rect.position = -rectangle_shape.size / 2.0
	static_body.add_child(visual_rect)
	
	parent_node.add_child(static_body)
