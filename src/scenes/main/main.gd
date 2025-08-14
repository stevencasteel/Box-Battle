# src/scenes/main/main.gd
extends Node

func _ready():
	if OS.is_debug_build():
		AssetPaths.validate_all_paths()
	
	# MODIFIED: Point to the new GUI-based title screen
	SceneManager.go_to_scene(AssetPaths.SCENE_GUI_TITLE_SCREEN)