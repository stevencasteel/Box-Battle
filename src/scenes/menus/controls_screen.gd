# src/scenes/menus/controls_screen.gd
## The controller for the controls display screen.
@tool
extends Control

# --- Constants ---
const MenuManagerScript = preload(AssetPaths.SCRIPT_MENU_MANAGER)

# --- Node References ---
@onready var back_button: StyledMenuItem = %BackButton

# --- Godot Lifecycle Methods ---
func _ready() -> void:
	back_button.text = "BACK"

	if not Engine.is_editor_hint():
		back_button.pressed.connect(_on_back_button_pressed)

		var menu_manager = MenuManagerScript.new()
		add_child(menu_manager)
		menu_manager.setup_menu([back_button])

		# --- Connect Feedback Handlers ---
		menu_manager.selection_changed.connect(_on_any_item_focused)
		back_button.mouse_entered.connect(CursorManager.set_pointer_state.bind(true))
		back_button.mouse_exited.connect(CursorManager.set_pointer_state.bind(false))

		await get_tree().process_frame
		back_button.grab_focus()

# --- Signal Handlers ---
func _on_any_item_focused() -> void:
	AudioManager.play_sfx(AssetPaths.SFX_UI_MOVE)

func _on_back_button_pressed() -> void:
	AudioManager.play_sfx(AssetPaths.SFX_UI_BACK)
	SceneManager.go_to_scene(AssetPaths.SCENE_OPTIONS_SCREEN)