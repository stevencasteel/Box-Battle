# src/core/builders/terrain_builder.gd
#
# Responsibility: To create all static level geometry (solid tiles,
# one-way platforms, hazards) based on parsed LevelBuildData.
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

# --- Tile Creation Functions (Moved from ArenaBuilder) ---

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
	parent_node.add_child(static_body)

func _create_oneway_platform(parent_node: Node, pos: Vector2) -> void:
	var static_body := StaticBody2D.new()
	static_body.position = pos
	static_body.collision_layer = 2 # 'world' layer
	static_body.add_to_group("world")
	static_body.add_to_group("oneway_platforms")
	
	var collision_shape := CollisionShape2D.new()
	collision_shape.one_way_collision = true
	collision_shape.position.y = -(Constants.TILE_SIZE / 2.0) + 5
	var rectangle_shape := RectangleShape2D.new()
	rectangle_shape.size = Vector2(Constants.TILE_SIZE, 10)
	collision_shape.shape = rectangle_shape
	
	static_body.add_child(collision_shape)
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
	parent_node.add_child(static_body)
