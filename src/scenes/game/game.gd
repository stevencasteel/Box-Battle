# src/scenes/game/game.gd
#
# This script orchestrates the setup of an arena battle. It handles both
# the initial smooth load from a pre-built level and in-place reloads for retries.
extends Node

func _ready():
	# PATH 1: Initial Load (Fast and Smooth)
	# Check if a level was pre-built by the loading screen.
	if GameManager.prebuilt_level:
		# Add the entire pre-built level to the scene tree in one fast operation.
		add_child(GameManager.prebuilt_level)
		# Clear the reference so it doesn't hold onto memory.
		GameManager.prebuilt_level = null
		
		# Yield a frame to ensure everything is properly set up in the scene tree.
		await get_tree().process_frame
		return # We're done.

	# PATH 2: Reload / Retry
	# If there's no pre-built level, we assume we're reloading the scene.
	# We check if we still know WHICH level to build.
	if not GameManager.current_encounter_script_path.is_empty():
		# Tell the ArenaBuilder to construct the level using the async method.
		# This will minimize hitches even on a reload.
		var level_container = await ArenaBuilder.build_level_async()
		add_child(level_container)
		await get_tree().process_frame
	
	# PATH 3: Critical Error
	# If we have no pre-built level AND no path, something is wrong.
	else:
		print("ERROR: Game scene loaded without a pre-built level or encounter path. Returning to title.")
		get_tree().change_scene_to_file(AssetPaths.SCENE_TITLE_SCREEN)