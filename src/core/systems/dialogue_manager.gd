# src/core/systems/dialogue_manager.gd
## An autoloaded singleton for managing and displaying dialogue.
##
## It will be responsible for loading [DialogueData] resources and commanding
## a UI scene to display the conversation line by line.
extends Node

# --- Private Member Variables ---
var _dialogue_box_instance: Control = null
var _is_dialogue_active: bool = false

# --- Public Methods ---

## Starts a conversation using the data from a [DialogueData] resource.
func start_conversation(_p_data: DialogueData) -> void:
	assert(false, "DialogueManager.start_conversation() is not yet implemented.")
	pass

# TODO: Add a method to advance the dialogue (e.g., on player input).
# func advance_dialogue() -> void:

# TODO: Add a method to properly instance and display the dialogue box UI.
# func _show_dialogue_box() -> void:

# TODO: Add a method to clean up and hide the dialogue box UI.
# func _hide_dialogue_box() -> void: