# src/scenes/game/game.gd
#
# This script orchestrates the setup of an arena battle. It loads a layout
# and an encounter file, builds the terrain from that data, and spawns the
# required entities like the player and boss.
extends Node

# --- Preloads ---
# Preload all required scenes and scripts via the AssetPaths singleton.
const PlayerScene = preload(AssetPaths.SCENE_PLAYER)
const ArenaLayout = preload(AssetPaths.SCRIPT_ARENA_00_LAYOUT)
const ArenaEncounter = preload(AssetPaths.SCRIPT_ARENA_00_ENCOUNTER)

func _ready():
	# Instantiate our data-only scripts to access their constants.
	var layout = ArenaLayout.new()
	var encounter = ArenaEncounter.new()

	var player_spawn_pos = Vector2.ZERO
	var boss_spawn_pos = Vector2.ZERO

	# --- Build Terrain and Find Spawns ---
	# Read the layout data and build the physical world tile by tile.
	for y in range(layout.TERRAIN_DATA.size()):
		var row_string = layout.TERRAIN_DATA[y]
		for x in range(row_string.length()):
			var tile_char = row_string[x]
			# Use the TILE_SIZE from our Constants singleton for positioning.
			var tile_pos = Vector2(x * Constants.TILE_SIZE, y * Constants.TILE_SIZE) + Vector2(Constants.TILE_SIZE / 2.0, Constants.TILE_SIZE / 2.0)

			match tile_char:
				'#':
					_create_solid_tile(tile_pos)
				'-':
					_create_oneway_platform(tile_pos)
				'^':
					_create_hazard_tile(tile_pos)
				# Check for entity markers defined in the encounter script.
				encounter.PLAYER_SPAWN_MARKER:
					player_spawn_pos = tile_pos
				encounter.BOSS_SPAWN_MARKER:
					boss_spawn_pos = tile_pos

	# --- Spawn Entities ---
	_spawn_player(player_spawn_pos)
	_spawn_boss(boss_spawn_pos, encounter.BOSS_SCENE)


# --- Helper Functions for Spawning and Building ---

func _spawn_player(pos: Vector2):
	var player_instance = PlayerScene.instantiate()
	player_instance.global_position = pos
	add_child(player_instance)

func _spawn_boss(pos: Vector2, scene: PackedScene):
	if scene == null: return
	var boss_instance = scene.instantiate()
	boss_instance.global_position = pos
	add_child(boss_instance)

func _create_solid_tile(pos: Vector2):
	var static_body = StaticBody2D.new()
	static_body.position = pos
	static_body.collision_layer = 2 # Corresponds to "world" layer
	static_body.add_to_group("world")
	var collision_shape = CollisionShape2D.new()
	var rectangle_shape = RectangleShape2D.new()
	rectangle_shape.size = Vector2(Constants.TILE_SIZE, Constants.TILE_SIZE)
	collision_shape.shape = rectangle_shape
	static_body.add_child(collision_shape)
	add_child(static_body)

# --- MODIFIED FUNCTION ---
func _create_oneway_platform(pos: Vector2):
	var static_body = StaticBody2D.new()
	static_body.position = pos
	static_body.collision_layer = 2 # Corresponds to "world" layer
	# Add to both groups so it acts as world geometry AND can be identified as a special platform.
	static_body.add_to_group("world")
	static_body.add_to_group("oneway_platforms") 
	
	var collision_shape = CollisionShape2D.new()
	collision_shape.one_way_collision = true
	# Position the collision shape at the top of the tile.
	# TILE_SIZE/2 is 25. The shape's height is 10, so its center is 5 from its top. 25-5=20.
	collision_shape.position.y = -20 
	
	var rectangle_shape = RectangleShape2D.new()
	# Make the platform thin for one-way collision to work best
	rectangle_shape.size = Vector2(Constants.TILE_SIZE, 10)
	collision_shape.shape = rectangle_shape
	static_body.add_child(collision_shape)
	add_child(static_body)

func _create_hazard_tile(pos: Vector2):
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
	add_child(static_body)