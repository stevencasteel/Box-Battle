# src/scenes/menus/options_screen.gd
## The controller for the main options menu scene.
@tool
extends "res://src/scenes/menus/base_menu_screen.gd"

# --- Node References ---
@onready var sound_button: StyledMenuItem = %SoundButton
@onready var controls_button: StyledMenuItem = %ControlsButton
@onready var credits_button: StyledMenuItem = %CreditsButton
@onready var back_button: StyledMenuItem = %BackButton

# --- Godot Lifecycle Methods ---
func _ready() -> void:
	sound_button.text = "SOUND"
	controls_button.text = "CONTROLS"
	credits_button.text = "CREDITS"
	back_button.text = "BACK"

	if not Engine.is_editor_hint():
		# --- Connect Unique Action Signals ---
		sound_button.pressed.connect(_on_sound_button_pressed)
		controls_button.pressed.connect(_on_controls_button_pressed)
		credits_button.pressed.connect(_on_credits_button_pressed)
		back_button.pressed.connect(_on_back_button_pressed)

		# --- Initialize Common Navigation & Feedback ---
		var all_items: Array[Control] = [
			sound_button, controls_button, credits_button, back_button
		]
		setup_menu_navigation(all_items, all_items)

		await get_tree().process_frame
		sound_button.grab_focus()

# --- Unique Signal Handlers ---
func _on_sound_button_pressed() -> void:
	SceneManager.go_to_scene(AssetPaths.SCENE_SOUND_SCREEN)

func _on_controls_button_pressed() -> void:
	SceneManager.go_to_scene(AssetPaths.SCENE_CONTROLS_SCREEN)

func _on_credits_button_pressed() -> void:
	SceneManager.go_to_scene(AssetPaths.SCENE_CREDITS_SCREEN)

func _on_back_button_pressed() -> void:
	AudioManager.play_sfx(AssetPaths.SFX_UI_BACK)
	SceneManager.go_to_scene(AssetPaths.SCENE_TITLE_SCREEN)