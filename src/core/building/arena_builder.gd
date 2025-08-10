# src/core/building/arena_builder.gd
#
# This singleton is now a high-level "Coordinator". Its single responsibility
# is to manage the overall process of level construction by delegating tasks
# to specialized builder classes.
extends Node

func build_level_async() -> Node:
	var level_container := Node.new()
	level_container.name = "LevelContainer"

	# --- 1. Load Encounter Data ---
	var encounter_path: String = GameManager.state.current_encounter_script_path
	if encounter_path.is_empty():
		push_error("ArenaBuilder: No encounter script specified in GameManager.")
		return level_container
		
	var encounter_script: Script = load(encounter_path)
	if not is_instance_valid(encounter_script):
		push_error("ArenaBuilder: Failed to load encounter script at: %s" % encounter_path)
		return level_container
		
	# --- 2. Parse Data (Now much simpler) ---
	# The parser now handles all the sub-loading and validation.
	var parser = LevelParser.new()
	var build_data = parser.parse_level_data(encounter_script)
	
	await get_tree().process_frame

	# --- 3. Build Terrain ---
	var terrain_builder = TerrainBuilder.new()
	await terrain_builder.build_terrain_async(level_container, build_data, get_tree())

	# --- 4. Spawn Entities ---
	var encounter_director = EncounterDirector.new()
	await encounter_director.spawn_entities_async(level_container, build_data, get_tree())

	# --- 5. Finalize ---
	await get_tree().process_frame
	
	return level_container