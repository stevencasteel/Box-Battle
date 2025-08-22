# src/data/dialogue/dialogue_line.gd
@tool
## A custom Resource holding the data for a single line of dialogue.
class_name DialogueLine
extends Resource

@export var speaker: String = ""
@export_multiline var text: String = ""
@export var portrait: Texture2D
@export var voice: AudioStream
@export_range(0.0, 5.0, 0.1) var wait_after: float = 0.2