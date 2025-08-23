# src/scenes/menus/title_screen.gd
## The controller for the main title screen scene.
@tool
extends Control

# --- Constants ---
const MenuManagerScript = preload(AssetPaths.SCRIPT_MENU_MANAGER)

# --- Node References ---
@onready var background_color: ColorRect = $BackgroundColor
@onready var start_button: StyledMenuItem = %StartButton
@onready var options_button: StyledMenuItem = %OptionsButton
@onready var exit_button: StyledMenuItem = %ExitButton
@onready var newgrounds_logo: LogoDisplay = %NewgroundsLogo
@onready var godot_logo: LogoDisplay = %GodotLogo
@onready var itch_logo: LogoDisplay = %ItchLogo
@onready var mute_button: MuteButton = $MuteButtonContainer/MuteButton

# --- Godot Lifecycle Methods ---


func _ready() -> void:
	background_color.color = Palette.COLOR_BACKGROUND

	start_button.text = "START GAME"
	options_button.text = "OPTIONS"
	exit_button.text = "EXIT"

	if not Engine.is_editor_hint():
		# --- Connect Action Signals ---
		start_button.pressed.connect(_on_start_button_pressed)
		options_button.pressed.connect(_on_options_button_pressed)
		exit_button.pressed.connect(_on_exit_button_pressed)
		newgrounds_logo.pressed.connect(_on_logo_pressed)
		godot_logo.pressed.connect(_on_logo_pressed)
		itch_logo.pressed.connect(_on_logo_pressed)

		# --- Connect All Items to Generic Feedback Handlers ---
		var all_interactive_items: Array[Control] = [
			start_button,
			options_button,
			exit_button,
			newgrounds_logo,
			godot_logo,
			itch_logo,
		]
		for item in all_interactive_items:
			item.pressed.connect(_on_any_item_pressed)

		var focusable_items: Array[StyledMenuItem] = [start_button, options_button, exit_button]
		for item in focusable_items:
			item.focus_entered.connect(_on_any_item_focused)
			item.mouse_entered.connect(CursorManager.set_pointer_state.bind(true))
			item.mouse_exited.connect(CursorManager.set_pointer_state.bind(false))

		# --- Initialize Menu Manager ---
		var menu_manager = MenuManagerScript.new()
		add_child(menu_manager)
		var menu_items: Array[Control] = [start_button, options_button, exit_button]
		menu_manager.setup_menu(menu_items)
		menu_manager.selection_changed.connect(_on_any_item_focused)

		await get_tree().process_frame
		start_button.grab_focus()


# --- Signal Handlers ---


func _on_any_item_pressed() -> void:
	AudioManager.play_sfx(AssetPaths.SFX_UI_SELECT)


func _on_any_item_focused() -> void:
	AudioManager.play_sfx(AssetPaths.SFX_UI_MOVE)


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
