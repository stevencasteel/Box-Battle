# src/scenes/main/main.gd
# This is the main entry point for the game, as defined in project.godot.
# Its only job is to immediately load and switch to the first real scene,
# which is our title screen.
extends Node

func _ready():
	# Using AssetPaths makes this transition type-safe and easy to manage.
	# 'call_deferred' waits until the current frame is finished before changing scenes,
	# which prevents potential physics or node errors during the switch.
	get_tree().call_deferred("change_scene_to_file", AssetPaths.SCENE_TITLE_SCREEN)