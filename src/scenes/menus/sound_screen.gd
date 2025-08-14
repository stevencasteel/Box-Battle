# src/scenes/menus/sound_screen.gd
@tool
extends Control

const MenuManagerScript = preload(AssetPaths.SCRIPT_MENU_MANAGER)
const CustomSliderScript = preload(AssetPaths.SCRIPT_CUSTOM_SLIDER)

@onready var menu_items_vbox: VBoxContainer = %MenuItemsVBox
@onready var back_button: StyledMenuItem = %BackButton

var master_volume_label: Label
var music_volume_label: Label
var sfx_volume_label: Label
var master_mute_checkbox: TextureButton
var music_mute_checkbox: TextureButton
var sfx_mute_checkbox: TextureButton

func _ready():
	for c in menu_items_vbox.get_children():
		c.queue_free()
	
	menu_items_vbox.add_child(_create_volume_row("MASTER", Settings.master_volume, "master"))
	menu_items_vbox.add_child(_create_volume_row("MUSIC", Settings.music_volume, "music"))
	menu_items_vbox.add_child(_create_volume_row("SFX", Settings.sfx_volume, "sfx"))

	_update_ui_from_settings()
	
	if not Engine.is_editor_hint():
		back_button.text = "BACK"
		back_button.pressed.connect(_on_back_button_pressed)
		
		Settings.audio_settings_changed.connect(_update_ui_from_settings)
		
		var menu_manager = MenuManagerScript.new()
		add_child(menu_manager)
		
		var menu_items: Array[Control] = [back_button]
		menu_manager.setup_menu(menu_items)
		
		await get_tree().process_frame
		back_button.grab_focus()
	else:
		back_button.text = "BACK"

func _exit_tree():
	if not Engine.is_editor_hint():
		if Settings.audio_settings_changed.is_connected(_update_ui_from_settings):
			Settings.audio_settings_changed.disconnect(_update_ui_from_settings)

func _update_ui_from_settings():
	if master_volume_label: master_volume_label.text = str(int(Settings.master_volume * 100))
	if music_volume_label: music_volume_label.text = str(int(Settings.music_volume * 100))
	if sfx_volume_label: sfx_volume_label.text = str(int(Settings.sfx_volume * 100))
	
	if master_mute_checkbox: _update_checkbox_texture(master_mute_checkbox, Settings.master_muted)
	if music_mute_checkbox: _update_checkbox_texture(music_mute_checkbox, Settings.music_muted)
	if sfx_mute_checkbox: _update_checkbox_texture(sfx_mute_checkbox, Settings.sfx_muted)

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
			master_volume_label = volume_label
			master_mute_checkbox = checkbox
			if not Engine.is_editor_hint():
				slider.value_changed.connect(func(new_value): Settings.master_volume = new_value)
				checkbox.pressed.connect(func(): Settings.master_muted = not Settings.master_muted)
		"music":
			music_volume_label = volume_label
			music_mute_checkbox = checkbox
			if not Engine.is_editor_hint():
				slider.value_changed.connect(func(new_value): Settings.music_volume = new_value)
				checkbox.pressed.connect(func(): Settings.music_muted = not Settings.music_muted)
		"sfx":
			sfx_volume_label = volume_label
			sfx_mute_checkbox = checkbox
			if not Engine.is_editor_hint():
				slider.value_changed.connect(func(new_value): Settings.sfx_volume = new_value)
				checkbox.pressed.connect(func(): Settings.sfx_muted = not Settings.sfx_muted)
	
	return hbox

func _update_checkbox_texture(button_ref: TextureButton, is_muted: bool):
	var new_texture = load(AssetPaths.SPRITE_CHECKBOX_UNCHECKED) if not is_muted else load(AssetPaths.SPRITE_CHECKBOX_CHECKED)
	if button_ref.texture_normal != new_texture:
		button_ref.texture_normal = new_texture

func _on_back_button_pressed():
	SceneManager.go_to_scene(AssetPaths.SCENE_OPTIONS_SCREEN)