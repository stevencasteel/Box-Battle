# src/core/systems/dialogue_manager.gd
## An autoloaded singleton for managing and displaying dialogue.
##
## It is responsible for loading [DialogueData] resources and commanding
## a UI scene to display the conversation line by line.
extends Node

signal conversation_started(dialogue_data)
signal line_shown(line_index, line: DialogueLine)
signal conversation_ended

const DialogueBoxScene = preload("res://src/ui/dialogue/dialogue_box.tscn")

var _current_data: DialogueData
var _current_index: int = -1
var _dialogue_box_instance: DialogueBox
var _ui_layer: CanvasLayer


func _ready() -> void:
	_ui_layer = CanvasLayer.new()
	_ui_layer.layer = 10
	_ui_layer.name = "DialogueUILayer"

	_dialogue_box_instance = DialogueBoxScene.instantiate()
	_dialogue_box_instance.visible = false

	_ui_layer.add_child.call_deferred(_dialogue_box_instance)
	get_tree().get_root().add_child.call_deferred(_ui_layer)

	_dialogue_box_instance.advance_requested.connect(_on_dialogue_box_advance_requested)
	_dialogue_box_instance.typing_finished.connect(_on_typing_finished)

	# THE FIX: Create a lambda function that accepts the event's payload
	# (which we ignore with '_') and calls our zero-argument function.
	EventBus.on(EventCatalog.SCENE_TRANSITION_STARTED, func(_payload): end_conversation())


## Checks if a conversation is currently active.
func is_conversation_active() -> bool:
	return is_instance_valid(_current_data)


## Starts a conversation using the data from a [DialogueData] resource.
func start_conversation(data: DialogueData) -> void:
	if not is_instance_valid(data) or data.lines.is_empty():
		push_error("DialogueManager: Attempted to start conversation with invalid or empty data.")
		return

	end_conversation()

	_current_data = data
	_current_index = 0

	_dialogue_box_instance.visible = true
	conversation_started.emit(data)
	_show_current_line()


## Ends the current conversation and hides the UI.
func end_conversation() -> void:
	if not is_instance_valid(_current_data):
		return

	_dialogue_box_instance.visible = false
	_current_data = null
	_current_index = -1
	conversation_ended.emit()


# --- Private Methods ---


func _show_current_line() -> void:
	if (
		not is_instance_valid(_current_data)
		or _current_index < 0
		or _current_index >= _current_data.lines.size()
	):
		end_conversation()
		return

	var line = _current_data.lines[_current_index]
	_dialogue_box_instance.display_line(line)
	line_shown.emit(_current_index, line)


func _advance_to_next_line() -> void:
	_current_index += 1
	if _current_index >= _current_data.lines.size():
		end_conversation()
	else:
		_show_current_line()


# --- Signal Handlers ---


func _on_dialogue_box_advance_requested() -> void:
	_advance_to_next_line()


func _on_typing_finished() -> void:
	var line = _current_data.lines[_current_index]
	if line.wait_after > 0.0:
		await get_tree().create_timer(line.wait_after).timeout
