# src/scenes/main/main.gd
## The main entry point for the entire application.
extends Node


func _ready() -> void:
	if OS.is_debug_build():
		AssetPaths.validate_all_paths()

	AudioManager.play_music(AssetPaths.MUSIC_MENU_LOOP)

	SceneManager.go_to_scene(AssetPaths.SCENE_TITLE_SCREEN)
