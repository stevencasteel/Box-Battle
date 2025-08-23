# src/ui/components/control_setting_row/control_setting_row.gd
@tool
## A self-contained UI component for a single row in the controls menu.
## Manages its own labels and layout.
class_name ControlSettingRow
extends HBoxContainer

# --- Node References ---
@onready var action_label: Label = %ActionLabel
@onready var keys_label: Label = %KeysLabel

# --- Public Properties ---
@export var action_text: String = "Action":
	set(value):
		action_text = value
		if is_instance_valid(action_label):
			action_label.text = action_text

@export var keys_text: String = "Keys":
	set(value):
		keys_text = value
		if is_instance_valid(keys_label):
			keys_label.text = keys_text


# --- Godot Lifecycle Methods ---
func _ready() -> void:
	if is_instance_valid(action_label):
		action_label.text = action_text
	if is_instance_valid(keys_label):
		keys_label.text = keys_text
