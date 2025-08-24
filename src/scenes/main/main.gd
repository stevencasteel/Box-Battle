# src/scenes/main/main.gd
## The main entry point for the entire application.
extends Node


func _ready() -> void:
	if OS.is_debug_build():
		AssetPaths.validate_all_paths()

	# THE FIX: Call the static method directly on the global class name.
	# This removes the need for a local constant and resolves the warning.
	BootManager.initialize_systems()

	AudioManager.play_music(AssetPaths.MUSIC_MENU_LOOP)

	SceneManager.go_to_scene(AssetPaths.SCENE_TITLE_SCREEN)
