# src/core/building/level_parser.gd
# REFACTORED: The parser now reads directly from our new data-driven
# EncounterData and LevelLayout .tres resource files.
class_name LevelParser
extends RefCounted

const GridUtilsScript = preload("res://src/core/util/grid_utils.gd")

# The function now accepts our new EncounterData resource as its input.
func parse_level_data(encounter_data: EncounterData) -> LevelBuildData:
	var data = LevelBuildData.new()
	if not is_instance_valid(encounter_data):
		push_error("LevelParser: Invalid EncounterData provided.")
		return data

	# Directly access the properties of the encounter resource.
	var layout: LevelLayout = encounter_data.level_layout
	if not is_instance_valid(layout):
		push_error("LevelParser: EncounterData is missing a valid LevelLayout.")
		return data
	
	var terrain_data_array: PackedStringArray = layout.terrain_data
	var grid_height = terrain_data_array.size()
	var grid_width = 0
	if grid_height > 0: grid_width = terrain_data_array[0].length()
	data.dimensions_tiles = Vector2i(grid_width, grid_height)
	
	# Get all spawn data directly from the resource.
	var player_marker = encounter_data.player_spawn_marker
	var boss_marker = encounter_data.boss_spawn_marker
	var minion_spawn_dict = encounter_data.minion_spawns

	for y in range(grid_height):
		var row_string: String = terrain_data_array[y]
		for x in range(row_string.length()):
			var tile_char: String = row_string[x]
			var tile_grid_pos = Vector2i(x, y)
			var tile_world_pos = GridUtilsScript.grid_to_world(tile_grid_pos)

			match tile_char:
				'#': data.terrain_tiles.append(tile_world_pos)
				'-': data.oneway_platforms.append(tile_world_pos)
				'^': data.hazard_tiles.append(tile_world_pos)
				'.': data.background_tiles.append(tile_grid_pos)
				_:
					data.background_tiles.append(tile_grid_pos)
					if tile_char == player_marker:
						data.player_spawn_pos = tile_world_pos
					elif tile_char == boss_marker:
						data.boss_spawn_pos = tile_world_pos
					elif minion_spawn_dict.has(tile_char):
						var scene_to_spawn = minion_spawn_dict[tile_char]
						var spawn_data = LevelBuildData.MinionSpawnData.new(scene_to_spawn, tile_world_pos)
						data.minion_spawns.append(spawn_data)
	
	return data
