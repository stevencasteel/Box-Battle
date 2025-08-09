# src/core/builders/level_parser.gd
#
# Responsibility: To parse the raw data from layout and encounter scripts and
# organize it into a structured LevelBuildData object. This class does not
# create any nodes; it only processes data.
class_name LevelParser
extends RefCounted

# The single public method of this class. It takes the arena script resources
# and returns a complete LevelBuildData resource.
#
# CORRECTED: The function signature now correctly expects Script resources,
# not instantiated Objects.
func parse_level_data(layout_script: Script, encounter_script: Script) -> LevelBuildData:
	var data = LevelBuildData.new()
	# We can still store the script resource for later use.
	data.encounter_script_object = encounter_script

	# Constants can be accessed directly from the script resource.
	for y in range(layout_script.TERRAIN_DATA.size()):
		var row_string: String = layout_script.TERRAIN_DATA[y]
		for x in range(row_string.length()):
			var tile_char: String = row_string[x]
			var tile_pos := Vector2(x * Constants.TILE_SIZE, y * Constants.TILE_SIZE) + Vector2(Constants.TILE_SIZE / 2.0, Constants.TILE_SIZE / 2.0)

			match tile_char:
				'#':
					data.terrain_tiles.append(tile_pos)
				'-':
					data.oneway_platforms.append(tile_pos)
				'^':
					data.hazard_tiles.append(tile_pos)
				_:
					if tile_char == encounter_script.PLAYER_SPAWN_MARKER:
						data.player_spawn_pos = tile_pos
					elif tile_char == encounter_script.BOSS_SPAWN_MARKER:
						data.boss_spawn_pos = tile_pos
	
	return data
