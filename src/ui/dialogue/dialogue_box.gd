# src/ui/dialogue/dialogue_box.gd
## The UI scene responsible for displaying dialogue text.
##
## It receives data from the [DialogueManager] and handles the visual
## presentation, including animated text effects.
class_name DialogueBox
extends Control

# TODO: Create @onready vars for Label nodes (character name, main text).
# @onready var name_label: Label = %NameLabel
# @onready var text_label: RichTextLabel = %TextLabel

# --- Public Methods ---

## Displays a single line of dialogue.
func display_line(_line_data: DialogueData.DialogueLine) -> void:
	assert(false, "DialogueBox.display_line() is not yet implemented.")
	pass

# --- Private Methods ---

# TODO: Implement a tween or timer-based text animation effect.
# func _animate_text(p_full_text: String) -> void: