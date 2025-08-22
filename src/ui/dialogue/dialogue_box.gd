# src/ui/dialogue/dialogue_box.gd
## The UI scene responsible for displaying dialogue text.
##
## It receives data from the [DialogueManager] and handles the visual
## presentation, including animated text effects.
class_name DialogueBox
extends Control

signal advance_requested
signal typing_finished

# --- Node References ---
@onready var name_label: Label = %NameLabel
@onready var text_label: RichTextLabel = %TextLabel

# --- Private Member Variables ---
var _typing_tween: Tween
var _is_typing: bool = false
var _typing_speed_chars_per_second: float = 60.0

# --- Godot Lifecycle Methods ---
func _unhandled_input(event: InputEvent) -> void:
	if not visible: return
	if event.is_action_pressed("ui_accept"):
		get_viewport().set_input_as_handled()
		_skip_or_advance()

# --- Public Methods ---

## Displays a single line of dialogue.
func display_line(line_data: DialogueLine) -> void:
	name_label.text = line_data.speaker
	text_label.bbcode_enabled = true
	text_label.text = line_data.text
	
	if is_instance_valid(_typing_tween):
		_typing_tween.kill()
		
	text_label.visible_ratio = 0.0
	_is_typing = true
	
	var parsed_text = text_label.get_parsed_text()
	var chars = parsed_text.length()
	var duration = max(0.1, float(chars) / _typing_speed_chars_per_second)
	
	_typing_tween = create_tween().set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_IN_OUT)
	_typing_tween.tween_property(text_label, "visible_ratio", 1.0, duration)
	_typing_tween.finished.connect(_on_typing_finished, CONNECT_ONE_SHOT)

# --- Private Methods ---
func _skip_or_advance() -> void:
	if _is_typing:
		if is_instance_valid(_typing_tween):
			_typing_tween.kill()
		text_label.visible_ratio = 1.0
		_on_typing_finished()
	else:
		advance_requested.emit()

func _on_typing_finished() -> void:
	_is_typing = false
	_typing_tween = null
	typing_finished.emit()