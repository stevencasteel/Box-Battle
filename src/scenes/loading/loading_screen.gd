# src/scenes/loading/loading_screen.gd
#
# This script handles the pre-building of the entire game level to prevent
# stuttering. It calls the ArenaBuilder to construct the level in memory.
extends Control

func _ready():
	# Ensure GameManager has a valid path before proceeding.
	if GameManager.current_encounter_script_path.is_empty():
		print("ERROR: No encounter script specified in GameManager. Returning to title.")
		get_tree().change_scene_to_file(AssetPaths.SCENE_TITLE_SCREEN)
		return

	# Tell the ArenaBuilder to construct the entire level. This is the
	# "heavy lifting" that will now happen behind the loading screen.
	GameManager.prebuilt_level = ArenaBuilder.build_level()
	
	# Wait for a single frame to ensure all creation processes are finalized.
	await get_tree().process_frame
	
	# Proceed to the main game scene.
	get_tree().change_scene_to_file(AssetPaths.SCENE_GAME)
