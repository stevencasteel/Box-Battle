# src/data/dialogue/dialogue_data.gd
@tool
## A custom Resource that holds the data for a single line of dialogue or a full conversation.
class_name DialogueData
extends Resource

## A container for a single line of dialogue text.
class DialogueLine extends Resource:
	@export var character_name: String = ""
	@export_multiline var text: String = ""
	# TODO: Add exports for character portraits, voice clips, etc.

# --- Editor Properties ---
@export var conversation: Array[DialogueLine] = []