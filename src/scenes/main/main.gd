# src/scenes/main/main.gd
# This is the main entry point for the game, as defined in project.godot.
# Its only job is to immediately delegate to the SceneManager.
extends Node

func _ready():
	# Validate asset paths in debug builds.
	if OS.is_debug_build():
		AssetPaths.validate_all_paths()

	# Delegate the initial scene load to our new centralized manager.
	SceneManager.go_to_title_screen()
