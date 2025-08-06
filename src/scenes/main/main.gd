# src/scenes/main/main.gd
# This is the main entry point for the game, as defined in project.godot.
# Its only job is to immediately load and switch to the first real scene,
# which is our title screen.
extends Node

func _ready():
	# Using AssetPaths makes this transition type-safe and easy to manage.
	# CRITICAL FIX: 'call_deferred' is REQUIRED here. The main scene cannot be
	# replaced immediately in its own _ready function, as the scene tree is
	# busy being set up. This defers the change to a safe point after the
	# current frame's processing.
	get_tree().call_deferred("change_scene_to_file", AssetPaths.SCENE_TITLE_SCREEN)
