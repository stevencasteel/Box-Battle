# src/core/building/level_parser.gd
#
# Responsibility: To parse the raw data from layout and encounter scripts.
# It now explicitly records the grid positions of empty/background tiles.
class_name LevelParser
extends RefCounted

const GridUtilsScript = preload("res://src/core/util/grid_utils.gd")

func parse_level_data(encounter_script: Script) -> LevelBuildData:
	var data = LevelBuildData.new()
	if not is_instance_valid(encounter_script):
		push_error("LevelParser: Received an invalid encounter script.")
		return data

	data.encounter_script_object = encounter_script

	var constants_map = encounter_script.get_script_constant_map()
	if not constants_map.has("LAYOUT_SCRIPT_PATH"):
		push_error("LevelParser: Encounter script '%s' is missing 'LAYOUT_SCRIPT_PATH' constant." % encounter_script.resource_path)
		return data

	var layout_path: String = constants_map["LAYOUT_SCRIPT_PATH"]
	var layout_script: Script = load(layout_path)
	if not is_instance_valid(layout_script):
		push_error("LevelParser: Failed to load layout script at path defined in encounter: %s" % layout_path)
		return data
	
	var terrain_data_array: Array = layout_script.TERRAIN_DATA
	var grid_height = terrain_data_array.size()
	var grid_width = 0
	if grid_height > 0:
		grid_width = terrain_data_array[0].length()
	data.dimensions_tiles = Vector2i(grid_width, grid_height)

	for y in range(grid_height):
		var row_string: String = terrain_data_array[y]
		for x in range(row_string.length()):
			var tile_char: String = row_string[x]
			var tile_grid_pos = Vector2i(x, y)
			var tile_world_pos = GridUtilsScript.grid_to_world(tile_grid_pos)

			match tile_char:
				'#':
					data.terrain_tiles.append(tile_world_pos)
				'-':
					data.oneway_platforms.append(tile_world_pos)
				'^':
					data.hazard_tiles.append(tile_world_pos)
				'.': # MODIFIED: Explicitly track background tiles from the ASCII map.
					data.background_tiles.append(tile_grid_pos)
				_:
					data.background_tiles.append(tile_grid_pos) # Also treat spawn markers as background
					if tile_char == encounter_script.PLAYER_SPAWN_MARKER:
						data.player_spawn_pos = tile_world_pos
					elif tile_char == encounter_script.BOSS_SPAWN_MARKER:
						data.boss_spawn_pos = tile_world_pos
	
	return data
