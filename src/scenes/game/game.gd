# src/scenes/game/game.gd
#
# This script orchestrates the setup of an arena battle. It handles both
# the initial smooth load from a pre-built level and in-place reloads for retries.
extends Node

# --- MODIFIED FUNCTION ---
func _ready():
	# PATH 1: Initial Load (Fast and Smooth)
	# Check if a level was pre-built by the loading screen.
	if GameManager.prebuilt_level:
		# Add the entire pre-built level to the scene tree in one fast operation.
		add_child(GameManager.prebuilt_level)
		# Clear the reference so it doesn't hold onto memory.
		GameManager.prebuilt_level = null
		return # We're done.

	# PATH 2: Reload / Retry
	# If there's no pre-built level, we assume we're reloading the scene.
	# We check if we still know WHICH level to build.
	if not GameManager.current_encounter_script_path.is_empty():
		print("No pre-built level found. Assuming retry. Rebuilding arena...")
		# Tell the ArenaBuilder to construct the level directly.
		# This will cause a brief hitch, which is acceptable for a retry.
		var level_container = ArenaBuilder.build_level()
		add_child(level_container)
	
	# PATH 3: Critical Error
	# If we have no pre-built level AND no path, something is wrong.
	else:
		print("ERROR: Game scene loaded without a pre-built level or encounter path. Returning to title.")
		get_tree().change_scene_to_file(AssetPaths.SCENE_TITLE_SCREEN)