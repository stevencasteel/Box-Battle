# src/core/building/level_parser.gd
#
# Responsibility: To parse the raw data from layout and encounter scripts and
# organize it into a structured LevelBuildData object. This class is now also
# responsible for loading the layout script and validating the data.
class_name LevelParser
extends RefCounted

# MODIFIED: This function is now smarter and more robust. It only needs the
# encounter_script and will handle loading and validating the layout script itself.
func parse_level_data(encounter_script: Script) -> LevelBuildData:
	var data = LevelBuildData.new()
	if not is_instance_valid(encounter_script):
		push_error("LevelParser: Received an invalid encounter script.")
		return data # Return empty data object

	data.encounter_script_object = encounter_script

	# --- NEW: Validation Step 1: Get Layout Path ---
	var constants_map = encounter_script.get_script_constant_map()
	if not constants_map.has("LAYOUT_SCRIPT_PATH"):
		push_error("LevelParser: Encounter script '%s' is missing 'LAYOUT_SCRIPT_PATH' constant." % encounter_script.resource_path)
		return data

	var layout_path: String = constants_map["LAYOUT_SCRIPT_PATH"]

	# --- NEW: Validation Step 2: Load Layout Script ---
	var layout_script: Script = load(layout_path)
	if not is_instance_valid(layout_script):
		push_error("LevelParser: Failed to load layout script at path defined in encounter: %s" % layout_path)
		return data

	# --- Original Parsing Logic (now guaranteed to have valid data) ---
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