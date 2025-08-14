# src/scenes/main/main.gd
extends Node

func _ready():
	if OS.is_debug_build():
		AssetPaths.validate_all_paths()
	
	# THE FIX: Start the menu music here, in the global entry point.
	# This ensures it runs once and persists across all menu scenes.
	AudioManager.play_music(AssetPaths.AUDIO_MUSIC_TITLE)
	
	SceneManager.go_to_scene(AssetPaths.SCENE_GUI_TITLE_SCREEN)