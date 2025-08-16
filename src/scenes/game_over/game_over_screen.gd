# src/scenes/game_over/game_over_screen.gd
## The controller for the "Game Over" screen.
@tool
extends Control

# --- Constants ---
const MenuManagerScript = preload(AssetPaths.SCRIPT_MENU_MANAGER)

# --- Node References ---
@onready var back_button: StyledMenuItem = %BackButton

# --- Godot Lifecycle Methods ---

func _ready() -> void:
	back_button.text = "BACK TO TITLE"

	if not Engine.is_editor_hint():
		back_button.pressed.connect(_on_back_button_pressed)

		var menu_manager = MenuManagerScript.new()
		add_child(menu_manager)
		menu_manager.setup_menu([back_button])

		await get_tree().process_frame
		back_button.grab_focus()

# --- Signal Handlers ---

func _on_back_button_pressed() -> void:
	SceneManager.go_to_scene(AssetPaths.SCENE_TITLE_SCREEN)