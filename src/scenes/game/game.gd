# src/scenes/game/game.gd
#
# This script acts as the host for the pre-built level. Its only job is to
# take the fully constructed level from the GameManager and add it to the scene.
extends Node

func _ready():
	# Check if a pre-built level actually exists in the GameManager.
	if GameManager.prebuilt_level:
		# Add the entire pre-built level to the scene tree in one fast operation.
		add_child(GameManager.prebuilt_level)
		# Clear the reference so it doesn't hold onto memory after we're done.
		GameManager.prebuilt_level = null
	else:
		# If we somehow got here without a level, return to the title screen.
		print("ERROR: Game scene loaded without a pre-built level. Returning to title.")
		get_tree().change_scene_to_file(AssetPaths.SCENE_TITLE_SCREEN)