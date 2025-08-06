# src/scenes/loading/loading_screen.gd
#
# This script handles the pre-building of the entire game level to prevent
# stuttering. It calls the ArenaBuilder to construct the level in memory and
# ensures proper frame yielding during the process.
extends Control

func _ready():
	# Ensure GameManager has a valid path before proceeding.
	if GameManager.current_encounter_script_path.is_empty():
		print("ERROR: No encounter script specified in GameManager. Returning to title.")
		get_tree().change_scene_to_file(AssetPaths.SCENE_TITLE_SCREEN)
		return

	# Start the asynchronous loading process
	_load_level()

func _load_level():
	# Yield a couple of frames to ensure the "Loading..." text is rendered
	# and visible before we start the heavy work.
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Tell the ArenaBuilder to construct the level asynchronously.
	# The 'await' keyword pauses this function until build_level_async is complete.
	GameManager.prebuilt_level = await ArenaBuilder.build_level_async()
	
	# Yield another couple of frames to ensure all creation processes are finalized
	# before we switch scenes.
	await get_tree().process_frame
	await get_tree().process_frame
	
	# Proceed to the main game scene using a direct change instead of deferred.
	get_tree().change_scene_to_file(AssetPaths.SCENE_GAME)
