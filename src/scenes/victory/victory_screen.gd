# src/scenes/victory/victory_screen.gd
## The controller for the "Victory" screen.
@tool
extends "res://src/scenes/menus/base_menu_screen.gd"

# --- Node References ---
@onready var back_button: StyledMenuItem = %BackButton

# --- Godot Lifecycle Methods ---
func _ready() -> void:
	back_button.text = "BACK TO TITLE"

	if not Engine.is_editor_hint():
		# --- Connect Unique Action Signals ---
		back_button.pressed.connect(_on_back_button_pressed)

		# --- Initialize Common Navigation & Feedback ---
		setup_menu_navigation([back_button], [back_button])

		await get_tree().process_frame
		back_button.grab_focus()

# --- Unique Signal Handlers ---
func _on_back_button_pressed() -> void:
	SceneManager.go_to_scene(AssetPaths.SCENE_TITLE_SCREEN)