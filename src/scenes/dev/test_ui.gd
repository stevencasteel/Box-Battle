# src/scenes/dev/test_ui.gd
#
# A simple script for the UI test scene. Its only purpose is to
# provide a convenient way to close the scene by pressing Escape.
extends Control

func _unhandled_input(event: InputEvent) -> void:
	# If the Escape key is pressed, quit the running scene.
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
