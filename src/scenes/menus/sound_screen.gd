# src/scenes/menus/sound_screen.gd
## The controller for the sound options menu.
@tool
extends Control

# --- Constants ---
const MenuManagerScript = preload(AssetPaths.SCRIPT_MENU_MANAGER)

# --- Node References ---
@onready var master_row: SoundSettingRow = %MasterRow
@onready var music_row: SoundSettingRow = %MusicRow
@onready var sfx_row: SoundSettingRow = %SfxRow
@onready var back_button: StyledMenuItem = %BackButton
@onready var mute_button: MuteButton = $MuteButtonContainer/MuteButton

# --- Godot Lifecycle Methods ---


func _ready() -> void:
	back_button.text = "BACK"

	if not Engine.is_editor_hint():
		# Connect component signals to the Settings singleton
		master_row.value_changed.connect(func(val): Settings.master_volume = val)
		master_row.mute_toggled.connect(func(val): Settings.master_muted = val)
		music_row.value_changed.connect(func(val): Settings.music_volume = val)
		music_row.mute_toggled.connect(func(val): Settings.music_muted = val)
		sfx_row.value_changed.connect(func(val): Settings.sfx_volume = val)
		sfx_row.mute_toggled.connect(func(val): Settings.sfx_muted = val)

		# Connect this screen to the Settings singleton to update visuals
		Settings.audio_settings_changed.connect(_update_ui_from_settings)
		_update_ui_from_settings() # Set initial state

		back_button.pressed.connect(_on_back_button_pressed)

		var menu_manager = MenuManagerScript.new()
		add_child(menu_manager)
		# NOTE: For now, only the back button is focusable with keyboard/controller.
		menu_manager.setup_menu([back_button])

		# --- Connect Feedback Handlers ---
		menu_manager.selection_changed.connect(_on_any_item_focused)
		var interactive_items: Array[Control] = [back_button, mute_button]
		for item in interactive_items:
			item.mouse_entered.connect(CursorManager.set_pointer_state.bind(true))
			item.mouse_exited.connect(CursorManager.set_pointer_state.bind(false))

		await get_tree().process_frame
		back_button.grab_focus()


func _exit_tree() -> void:
	if not Engine.is_editor_hint():
		if Settings.audio_settings_changed.is_connected(_update_ui_from_settings):
			Settings.audio_settings_changed.disconnect(_update_ui_from_settings)


# --- Private Methods ---


func _update_ui_from_settings() -> void:
	# This function now only tells the rows to update themselves.
	# It doesn't know *how* they update.
	if is_instance_valid(master_row):
		master_row.set_slider_value(Settings.master_volume)
		master_row.set_mute_state(Settings.master_muted)
	if is_instance_valid(music_row):
		music_row.set_slider_value(Settings.music_volume)
		music_row.set_mute_state(Settings.music_muted)
	if is_instance_valid(sfx_row):
		sfx_row.set_slider_value(Settings.sfx_volume)
		sfx_row.set_mute_state(Settings.sfx_muted)


# --- Signal Handlers ---


func _on_any_item_focused() -> void:
	AudioManager.play_sfx(AssetPaths.SFX_UI_MOVE)


func _on_back_button_pressed() -> void:
	AudioManager.play_sfx(AssetPaths.SFX_UI_BACK)
	SceneManager.go_to_scene(AssetPaths.SCENE_OPTIONS_SCREEN)
