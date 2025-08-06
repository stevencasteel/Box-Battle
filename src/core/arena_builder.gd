# src/core/arena_builder.gd
#
# This singleton is responsible for all procedural level construction.
# It contains the logic for creating terrain tiles and spawning entities.
extends Node

const PlayerScene = preload(AssetPaths.SCENE_PLAYER)
const GameHUDScene = preload(AssetPaths.SCENE_GAME_HUD) # <-- NEW

# --- NEW ASYNC FUNCTION ---
# This function builds the level asynchronously to prevent frame drops
func build_level_async() -> Node:
	# Create the container "box" that will hold the entire level.
	var level_container = Node.new()
	level_container.name = "LevelContainer"

	var encounter_path = GameManager.current_encounter_script_path
	var layout_path = encounter_path.replace("encounter.gd", "layout.gd")
	
	var ArenaLayout = load(layout_path)
	var ArenaEncounter = load(encounter_path)

	var layout = ArenaLayout.new()
	var encounter = ArenaEncounter.new()

	var player_spawn_pos = Vector2.ZERO
	var boss_spawn_pos = Vector2.ZERO
	var terrain_tiles = []
	var oneway_platforms = []
	var hazard_tiles = []

	# First pass: collect all tile data
	for y in range(layout.TERRAIN_DATA.size()):
		var row_string = layout.TERRAIN_DATA[y]
		for x in range(row_string.length()):
			var tile_char = row_string[x]
			var tile_pos = Vector2(x * Constants.TILE_SIZE, y * Constants.TILE_SIZE) + Vector2(Constants.TILE_SIZE / 2.0, Constants.TILE_SIZE / 2.0)

			match tile_char:
				'#':
					terrain_tiles.append(tile_pos)
				'-':
					oneway_platforms.append(tile_pos)
				'^':
					hazard_tiles.append(tile_pos)
				encounter.PLAYER_SPAWN_MARKER:
					player_spawn_pos = tile_pos
				encounter.BOSS_SPAWN_MARKER:
					boss_spawn_pos = tile_pos
	
	# Yield every few iterations to prevent frame drops
	await get_tree().process_frame
	
	# Create terrain tiles in batches
	var batch_size = 20
	for i in range(terrain_tiles.size()):
		_create_solid_tile(level_container, terrain_tiles[i])
		if i % batch_size == 0:
			await get_tree().process_frame
	
	# Create oneway platforms in batches
	for i in range(oneway_platforms.size()):
		_create_oneway_platform(level_container, oneway_platforms[i])
		if i % batch_size == 0:
			await get_tree().process_frame
	
	# Create hazard tiles in batches
	for i in range(hazard_tiles.size()):
		_create_hazard_tile(level_container, hazard_tiles[i])
		if i % batch_size == 0:
			await get_tree().process_frame
	
	await get_tree().process_frame
	
	# Pre-instantiate entities
	await _spawn_player_async(level_container, player_spawn_pos)
	await _spawn_boss_async(level_container, boss_spawn_pos, encounter.BOSS_SCENE)
	
	# Instantiate the HUD
	var hud_instance = GameHUDScene.instantiate()
	level_container.add_child(hud_instance)

	await get_tree().process_frame
	
	# Return the finished, self-contained level.
	return level_container

# --- MODIFIED FUNCTION (kept for compatibility but now calls async version) ---
func build_level() -> Node:
	return await build_level_async()

# --- Async Entity Spawning Functions ---

func _spawn_player_async(parent_node: Node, pos: Vector2):
	var player_instance = PlayerScene.instantiate()
	player_instance.global_position = pos
	parent_node.add_child(player_instance)
	await get_tree().process_frame

func _spawn_boss_async(parent_node: Node, pos: Vector2, scene: PackedScene):
	if scene == null: return
	var boss_instance = scene.instantiate()
	boss_instance.global_position = pos
	parent_node.add_child(boss_instance)
	await get_tree().process_frame

# --- Original sync functions (no longer used by async path but kept for potential direct use) ---

func _spawn_player(parent_node: Node, pos: Vector2):
	var player_instance = PlayerScene.instantiate()
	player_instance.global_position = pos
	parent_node.add_child(player_instance)

func _spawn_boss(parent_node: Node, pos: Vector2, scene: PackedScene):
	if scene == null: return
	var boss_instance = scene.instantiate()
	boss_instance.global_position = pos
	parent_node.add_child(boss_instance)

# --- Optimized Tile Creation Functions ---

func _create_solid_tile(parent_node: Node, pos: Vector2):
	var static_body = StaticBody2D.new()
	static_body.position = pos
	static_body.collision_layer = 2
	static_body.add_to_group("world")
	
	var collision_shape = CollisionShape2D.new()
	var rectangle_shape = RectangleShape2D.new()
	rectangle_shape.size = Vector2(Constants.TILE_SIZE, Constants.TILE_SIZE)
	collision_shape.shape = rectangle_shape
	
	static_body.add_child(collision_shape)
	parent_node.add_child(static_body)

func _create_oneway_platform(parent_node: Node, pos: Vector2):
	var static_body = StaticBody2D.new()
	static_body.position = pos
	static_body.collision_layer = 2
	static_body.add_to_group("world")
	static_body.add_to_group("oneway_platforms")
	
	var collision_shape = CollisionShape2D.new()
	collision_shape.one_way_collision = true
	collision_shape.position.y = -20
	var rectangle_shape = RectangleShape2D.new()
	rectangle_shape.size = Vector2(Constants.TILE_SIZE, 10)
	collision_shape.shape = rectangle_shape
	
	static_body.add_child(collision_shape)
	parent_node.add_child(static_body)

func _create_hazard_tile(parent_node: Node, pos: Vector2):
	var static_body = StaticBody2D.new()
	static_body.position = pos
	static_body.collision_layer = 10
	static_body.add_to_group("world")
	static_body.add_to_group("hazard")
	
	var collision_shape = CollisionShape2D.new()
	var rectangle_shape = RectangleShape2D.new()
	rectangle_shape.size = Vector2(Constants.TILE_SIZE, Constants.TILE_SIZE)
	collision_shape.shape = rectangle_shape
	
	static_body.add_child(collision_shape)
	parent_node.add_child(static_body)