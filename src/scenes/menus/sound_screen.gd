# src/scenes/menus/sound_screen.gd
## The controller for the sound options menu.
@tool
extends Control

# --- Constants ---
const MenuManagerScript = preload(AssetPaths.SCRIPT_MENU_MANAGER)
const CustomSliderScript = preload(AssetPaths.SCRIPT_CUSTOM_SLIDER)

# --- Node References ---
@onready var menu_items_vbox: VBoxContainer = %MenuItemsVBox
@onready var back_button: StyledMenuItem = %BackButton
@onready var mute_button: MuteButton = $MuteButtonContainer/MuteButton

# --- Private Member Variables ---
var _master_volume_label: Label
var _music_volume_label: Label
var _sfx_volume_label: Label
var _master_mute_checkbox: TextureButton
var _music_mute_checkbox: TextureButton
var _sfx_mute_checkbox: TextureButton

# --- Godot Lifecycle Methods ---


func _ready() -> void:
	for c in menu_items_vbox.get_children():
		c.queue_free()
	menu_items_vbox.add_child(_create_volume_row("MASTER", Settings.master_volume, "master"))
	menu_items_vbox.add_child(_create_volume_row("MUSIC", Settings.music_volume, "music"))
	menu_items_vbox.add_child(_create_volume_row("SFX", Settings.sfx_volume, "sfx"))
	_update_ui_from_settings()

	back_button.text = "BACK"

	if not Engine.is_editor_hint():
		back_button.pressed.connect(_on_back_button_pressed)
		Settings.audio_settings_changed.connect(_update_ui_from_settings)
		# THE FIX: Mute button connections are no longer needed here.

		var menu_manager = MenuManagerScript.new()
		add_child(menu_manager)
		menu_manager.setup_menu([back_button])

		# --- Connect Feedback Handlers ---
		menu_manager.selection_changed.connect(_on_any_item_focused)
		var interactive_items: Array[Control] = [back_button, mute_button]
		for item in interactive_items:
			item.mouse_entered.connect(CursorManager.set_pointer_state.bind(true))
			item.mouse_exited.connect(CursorManager.set_pointer_state.bind(false))
		
		# THE FIX: Mute button handles its own select sound now.

		await get_tree().process_frame
		back_button.grab_focus()


func _exit_tree() -> void:
	if not Engine.is_editor_hint():
		if Settings.audio_settings_changed.is_connected(_update_ui_from_settings):
			Settings.audio_settings_changed.disconnect(_update_ui_from_settings)


# --- Private Methods ---


func _update_ui_from_settings() -> void:
	if _master_volume_label:
		_master_volume_label.text = str(int(Settings.master_volume * 100))
	if _music_volume_label:
		_music_volume_label.text = str(int(Settings.music_volume * 100))
	if _sfx_volume_label:
		_sfx_volume_label.text = str(int(Settings.sfx_volume * 100))
	if _master_mute_checkbox:
		_update_checkbox_texture(_master_mute_checkbox, Settings.master_muted)
	if _music_mute_checkbox:
		_update_checkbox_texture(_music_mute_checkbox, Settings.music_muted)
	if _sfx_mute_checkbox:
		_update_checkbox_texture(_sfx_mute_checkbox, Settings.sfx_muted)
	# THE FIX: Mute button updates itself, so no need to call its update_icon method.


func _create_volume_row(label_text: String, initial_volume: float, type: String) -> HBoxContainer:
	var hbox = HBoxContainer.new()
	hbox.alignment = HBoxContainer.ALIGNMENT_CENTER
	hbox.add_theme_constant_override("separation", 20)

	var row_label = Label.new()
	row_label.text = label_text
	row_label.custom_minimum_size.x = 220
	row_label.add_theme_font_override("font", load(AssetPaths.FONT_MAIN_BOLD))
	row_label.add_theme_font_size_override("font_size", 48)
	hbox.add_child(row_label)

	var slider = CustomSliderScript.new()
	slider.set_value(initial_volume)
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	slider.focus_mode = FOCUS_NONE
	hbox.add_child(slider)

	var volume_label = Label.new()
	volume_label.custom_minimum_size.x = 120
	volume_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	volume_label.add_theme_font_override("font", load(AssetPaths.FONT_MAIN_REGULAR))
	volume_label.add_theme_font_size_override("font_size", 48)
	hbox.add_child(volume_label)

	var checkbox = TextureButton.new()
	checkbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	checkbox.focus_mode = FOCUS_NONE
	hbox.add_child(checkbox)

	match type:
		"master":
			_master_volume_label = volume_label
			_master_mute_checkbox = checkbox
			if not Engine.is_editor_hint():
				slider.value_changed.connect(func(val): Settings.master_volume = val)
				checkbox.pressed.connect(func(): Settings.master_muted = not Settings.master_muted)
		"music":
			_music_volume_label = volume_label
			_music_mute_checkbox = checkbox
			if not Engine.is_editor_hint():
				slider.value_changed.connect(func(val): Settings.music_volume = val)
				checkbox.pressed.connect(func(): Settings.music_muted = not Settings.music_muted)
		"sfx":
			_sfx_volume_label = volume_label
			_sfx_mute_checkbox = checkbox
			if not Engine.is_editor_hint():
				slider.value_changed.connect(func(val): Settings.sfx_volume = val)
				checkbox.pressed.connect(func(): Settings.sfx_muted = not Settings.sfx_muted)

	return hbox


func _update_checkbox_texture(button_ref: TextureButton, is_muted: bool) -> void:
	var new_texture = (
		load(AssetPaths.SPRITE_CHECKBOX_UNCHECKED)
		if not is_muted
		else load(AssetPaths.SPRITE_CHECKBOX_CHECKED)
	)
	if button_ref.texture_normal != new_texture:
		button_ref.texture_normal = new_texture


# --- Signal Handlers ---

func _on_any_item_focused() -> void:
	AudioManager.play_sfx(AssetPaths.SFX_UI_MOVE)


func _on_back_button_pressed() -> void:
	AudioManager.play_sfx(AssetPaths.SFX_UI_BACK)
	SceneManager.go_to_scene(AssetPaths.SCENE_OPTIONS_SCREEN)
