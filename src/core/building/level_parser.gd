# src/core/building/level_parser.gd
#
# The parser is now capable of identifying and storing data for
# multiple, user-defined minion spawn markers.
class_name LevelParser
extends RefCounted

const GridUtilsScript = preload("res://src/core/util/grid_utils.gd")

func parse_level_data(encounter_script: Script) -> LevelBuildData:
	var data = LevelBuildData.new()
	if not is_instance_valid(encounter_script): return data

	data.encounter_script_object = encounter_script

	var constants = encounter_script.get_script_constant_map()
	if not constants.has("LAYOUT_SCRIPT_PATH"): return data

	var layout_script: Script = load(constants["LAYOUT_SCRIPT_PATH"])
	if not is_instance_valid(layout_script): return data
	
	var terrain_data_array: Array = layout_script.TERRAIN_DATA
	var grid_height = terrain_data_array.size()
	var grid_width = 0
	if grid_height > 0: grid_width = terrain_data_array[0].length()
	data.dimensions_tiles = Vector2i(grid_width, grid_height)
	
	# Get the minion spawn dictionary from the encounter script.
	var minion_spawn_dict = constants.get("MINION_SPAWNS", {})

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
					if tile_char == constants["PLAYER_SPAWN_MARKER"]:
						data.player_spawn_pos = tile_world_pos
					elif tile_char == constants["BOSS_SPAWN_MARKER"]:
						data.boss_spawn_pos = tile_world_pos
					# NEW: Check if the character is a defined minion marker.
					elif minion_spawn_dict.has(tile_char):
						var scene_path = minion_spawn_dict[tile_char]
						var spawn_data = LevelBuildData.MinionSpawnData.new(scene_path, tile_world_pos)
						data.minion_spawns.append(spawn_data)
	
	return data
