# src/scenes/menus/title_screen.gd
## The controller for the main title screen scene.
@tool
extends "res://src/scenes/menus/base_menu_screen.gd"

# --- Node References ---
@onready var background_color: ColorRect = $BackgroundColor
@onready var start_button: StyledMenuItem = %StartButton
@onready var options_button: StyledMenuItem = %OptionsButton
@onready var exit_button: StyledMenuItem = %ExitButton
@onready var newgrounds_logo: LogoDisplay = %NewgroundsLogo
@onready var godot_logo: LogoDisplay = %GodotLogo
@onready var itch_logo: LogoDisplay = %ItchLogo

# --- Godot Lifecycle Methods ---
func _ready() -> void:
	background_color.color = Palette.COLOR_BACKGROUND

	start_button.text = "START GAME"
	options_button.text = "OPTIONS"
	exit_button.text = "EXIT"

	if not Engine.is_editor_hint():
		# --- Connect Unique Action Signals ---
		start_button.pressed.connect(_on_start_button_pressed)
		options_button.pressed.connect(_on_options_button_pressed)
		exit_button.pressed.connect(_on_exit_button_pressed)
		newgrounds_logo.pressed.connect(_on_logo_pressed)
		godot_logo.pressed.connect(_on_logo_pressed)
		itch_logo.pressed.connect(_on_logo_pressed)

		# --- Initialize Common Navigation & Feedback ---
		var focusable_items: Array[Control] = [start_button, options_button, exit_button]
		# THE FIX: Construct the array in a single statement to preserve its type.
		var all_items: Array[Control] = [
			start_button, options_button, exit_button, 
			newgrounds_logo, godot_logo, itch_logo
		]
		setup_menu_navigation(focusable_items, all_items)

		await get_tree().process_frame
		start_button.grab_focus()

# --- Unique Signal Handlers ---
func _on_start_button_pressed() -> void:
	SceneManager.start_game(AssetPaths.ENCOUNTER_00)

func _on_options_button_pressed() -> void:
	SceneManager.go_to_scene(AssetPaths.SCENE_OPTIONS_SCREEN)

func _on_exit_button_pressed() -> void:
	AudioManager.play_sfx(AssetPaths.SFX_UI_BACK)
	await get_tree().create_timer(0.2).timeout
	get_tree().quit()

func _on_logo_pressed(logo_name: String) -> void:
	print("%s Pressed" % logo_name)
