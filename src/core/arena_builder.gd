# src/core/arena_builder.gd
#
# This singleton is now a high-level "Coordinator". Its single responsibility
# is to manage the overall process of level construction by delegating tasks
# to specialized builder classes.
extends Node

# This function is now much cleaner and easier to read. It's a clear,
# step-by-step recipe for building a level.
func build_level_async() -> Node:
	var level_container := Node.new()
	level_container.name = "LevelContainer"

	# --- 1. Load Raw Data ---
	var encounter_path: String = GameManager.current_encounter_script_path
	if encounter_path.is_empty():
		push_error("ArenaBuilder: No encounter script specified in GameManager.")
		return level_container
		
	var layout_path: String = encounter_path.replace("encounter.gd", "layout.gd")
	var layout_script: Script = load(layout_path)
	var encounter_script: Script = load(encounter_path)

	if not layout_script or not encounter_script:
		push_error("ArenaBuilder: Failed to load layout or encounter script.")
		return level_container

	# --- 2. Parse Data ---
	var parser = LevelParser.new()
	var build_data = parser.parse_level_data(layout_script.new(), encounter_script.new())
	
	await get_tree().process_frame

	# --- 3. Build Terrain ---
	var terrain_builder = TerrainBuilder.new()
	# FIX: Pass the SceneTree reference to the builder.
	await terrain_builder.build_terrain_async(level_container, build_data, get_tree())

	# --- 4. Spawn Entities ---
	var encounter_director = EncounterDirector.new()
	# FIX: Pass the SceneTree reference to the director.
	await encounter_director.spawn_entities_async(level_container, build_data, get_tree())

	# --- 5. Finalize ---
	await get_tree().process_frame
	
	return level_container
