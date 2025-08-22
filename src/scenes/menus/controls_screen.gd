# src/scenes/menus/controls_screen.gd
## The controller for the controls display screen.
@tool
extends Control

# --- Constants ---
const MenuManagerScript = preload(AssetPaths.SCRIPT_MENU_MANAGER)
const CONTROLS_DATA = [
	{"action": "Movement", "keys": "Arrow Keys / WASD / Mouse"},
	{"action": "Primary Action", "keys": "X / . / Space / Left-Click"},
	{"action": "Secondary Action", "keys": "C / , / Shift / Right-Click"},
	{"action": "Tertiary Action", "keys": "Z / / / Ctrl / Middle-Click"},
	{"action": "Pause / Menu", "keys": "Enter / P / Escape"},
	{"action": "Back / Cancel", "keys": "Escape / Backspace"}
]

# --- Node References ---
@onready var controls_vbox: VBoxContainer = %ControlsVBox
@onready var back_button: StyledMenuItem = %BackButton

# --- Godot Lifecycle Methods ---


func _ready() -> void:
	# --- Procedurally build the UI rows ---
	for c in controls_vbox.get_children():
		c.queue_free()
	for data in CONTROLS_DATA:
		controls_vbox.add_child(_create_control_row(data))

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


# --- Private Methods ---


func _create_control_row(data: Dictionary) -> HBoxContainer:
	var hbox = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	hbox.add_theme_constant_override("separation", 40)

	var action_label = Label.new()
	action_label.text = data.action
	action_label.custom_minimum_size.x = 400
	action_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	action_label.add_theme_font_override("font", load(AssetPaths.FONT_MAIN_BOLD))
	action_label.add_theme_font_size_override("font_size", 36)
	hbox.add_child(action_label)

	var keys_label = Label.new()
	keys_label.text = data.keys
	keys_label.custom_minimum_size.x = 500
	keys_label.add_theme_font_override("font", load(AssetPaths.FONT_MAIN_REGULAR))
	keys_label.add_theme_font_size_override("font_size", 36)
	hbox.add_child(keys_label)

	return hbox


# --- Signal Handlers ---


func _on_any_item_focused() -> void:
	AudioManager.play_sfx(AssetPaths.SFX_UI_MOVE)


func _on_back_button_pressed() -> void:
	AudioManager.play_sfx(AssetPaths.SFX_UI_BACK)
	SceneManager.go_to_scene(AssetPaths.SCENE_OPTIONS_SCREEN)
