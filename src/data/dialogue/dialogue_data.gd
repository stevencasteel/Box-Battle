# src/data/dialogue/dialogue_data.gd
@tool
## A custom Resource that holds the data for a full conversation.
class_name DialogueData
extends Resource

## An array of DialogueLine resources that make up the conversation.
@export var lines: Array[DialogueLine] = []
