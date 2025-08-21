# src/scenes/menus/options_screen.gd
## The controller for the main options menu scene.
@tool
extends Control

# --- Constants ---
const MenuManagerScript = preload(AssetPaths.SCRIPT_MENU_MANAGER)

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
		# --- Connect Signals ---
		sound_button.pressed.connect(_on_sound_button_pressed)
		controls_button.pressed.connect(_on_controls_button_pressed)
		credits_button.pressed.connect(_on_credits_button_pressed)
		back_button.pressed.connect(_on_back_button_pressed)

		# --- Initialize Menu Manager ---
		var menu_manager = MenuManagerScript.new()
		add_child(menu_manager)
		var menu_items: Array[Control] = [sound_button, controls_button, credits_button, back_button]
		menu_manager.setup_menu(menu_items)
		
		# --- Connect Feedback Handlers ---
		menu_manager.selection_changed.connect(_on_any_item_focused)
		var generic_menu_items = [sound_button, controls_button, credits_button]
		for item in generic_menu_items:
			item.pressed.connect(_on_any_item_pressed)
			item.mouse_entered.connect(CursorManager.set_pointer_state.bind(true))
			item.mouse_exited.connect(CursorManager.set_pointer_state.bind(false))
		
		# Connect feedback for the back button separately
		back_button.mouse_entered.connect(CursorManager.set_pointer_state.bind(true))
		back_button.mouse_exited.connect(CursorManager.set_pointer_state.bind(false))

		await get_tree().process_frame
		sound_button.grab_focus()

# --- Signal Handlers ---

func _on_any_item_pressed() -> void:
	AudioManager.play_sfx(AssetPaths.SFX_UI_SELECT)

func _on_any_item_focused() -> void:
	AudioManager.play_sfx(AssetPaths.SFX_UI_MOVE)

func _on_sound_button_pressed() -> void:
	SceneManager.go_to_scene(AssetPaths.SCENE_SOUND_SCREEN)

func _on_controls_button_pressed() -> void:
	SceneManager.go_to_scene(AssetPaths.SCENE_CONTROLS_SCREEN)

func _on_credits_button_pressed() -> void:
	SceneManager.go_to_scene(AssetPaths.SCENE_CREDITS_SCREEN)

func _on_back_button_pressed() -> void:
	AudioManager.play_sfx(AssetPaths.SFX_UI_BACK)
	SceneManager.go_to_scene(AssetPaths.SCENE_TITLE_SCREEN)