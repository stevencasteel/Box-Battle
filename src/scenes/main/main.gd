# src/scenes/main/main.gd
extends Node

func _ready():
	if OS.is_debug_build():
		AssetPaths.validate_all_paths()
	
	AudioManager.play_music(AssetPaths.MUSIC_MENU_LOOP)
	
	# THE FIX: Point to the final, correct title screen path.
	SceneManager.go_to_scene(AssetPaths.SCENE_TITLE_SCREEN)