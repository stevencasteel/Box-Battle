# src/ui/screens/sound_menu/sound_menu.gd
# Manages the sound settings screen, now with a layout that is
# pixel-perfect consistent with the Credits menu.
extends Control

const CustomSliderScript = preload(AssetPaths.SCRIPT_CUSTOM_SLIDER)
const MenuManager = preload(AssetPaths.SCRIPT_MENU_MANAGER)

var master_volume_label: Label
var music_volume_label: Label
var sfx_volume_label: Label
var master_mute_checkbox: TextureButton
var music_mute_checkbox: TextureButton
var sfx_mute_checkbox: TextureButton

func _ready():
	EventBus.emit(EventCatalog.MENU_OPENED)
	
	# --- 1. Title (matches credits_menu.gd) ---
	var title_label = Label.new()
	title_label.text = "Sound Settings"
	title_label.add_theme_font_override("font", load(AssetPaths.FONT_BLACK))
	title_label.add_theme_font_size_override("font_size", 96)
	title_label.size.x = get_viewport_rect().size.x
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.position.y = 80
	add_child(title_label)

	# --- 2. Content (centered vertically) ---
	var content_vbox = VBoxContainer.new()
	content_vbox.set_anchors_preset(Control.PRESET_CENTER)
	content_vbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
	content_vbox.grow_vertical = Control.GROW_DIRECTION_BOTH
	content_vbox.add_theme_constant_override("separation", 50)
	add_child(content_vbox)
	
	content_vbox.add_child(_create_volume_row("MASTER", Settings.master_volume, "master"))
	content_vbox.add_child(_create_volume_row("MUSIC", Settings.music_volume, "music"))
	content_vbox.add_child(_create_volume_row("SFX", Settings.sfx_volume, "sfx"))

	# --- 3. Back Button (matches credits_menu.gd) ---
	var back_button = TextureButton.new()
	back_button.texture_normal = load(AssetPaths.SPRITE_MENU_ITEM_BACK)
	# CORRECTED: Use the exact centering formula and add as a direct child.
	back_button.position = Vector2((get_viewport_rect().size.x - back_button.size.x) / 2.0, 800)
	back_button.pressed.connect(_on_back_button_pressed)
	add_child(back_button)

	# --- Menu Manager ---
	var menu = MenuManager.new()
	add_child(menu)
	menu.setup_menu([MenuManager.MenuItem.new(back_button, "BACK")])

func _exit_tree():
	EventBus.emit(EventCatalog.MENU_CLOSED)

func _process(_delta):
	if master_volume_label: master_volume_label.text = str(int(Settings.master_volume * 100))
	if music_volume_label: music_volume_label.text = str(int(Settings.music_volume * 100))
	if sfx_volume_label: sfx_volume_label.text = str(int(Settings.sfx_volume * 100))
	
	if master_mute_checkbox: _update_checkbox_texture(master_mute_checkbox, Settings.master_muted)
	if music_mute_checkbox: _update_checkbox_texture(music_mute_checkbox, Settings.music_muted)
	if sfx_mute_checkbox: _update_checkbox_texture(sfx_mute_checkbox, Settings.sfx_muted)

func _create_volume_row(label_text: String, initial_volume: float, type: String) -> HBoxContainer:
	var hbox = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	hbox.add_theme_constant_override("separation", 20)

	var row_label = Label.new()
	row_label.text = label_text
	row_label.custom_minimum_size.x = 220
	row_label.add_theme_font_override("font", load(AssetPaths.FONT_BOLD))
	row_label.add_theme_font_size_override("font_size", 48)
	hbox.add_child(row_label)

	var slider = CustomSliderScript.new()
	slider.set_value(initial_volume)
	slider.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox.add_child(slider)

	var volume_label = Label.new()
	volume_label.custom_minimum_size.x = 120
	volume_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	volume_label.add_theme_font_override("font", load(AssetPaths.FONT_REGULAR))
	volume_label.add_theme_font_size_override("font_size", 48)
	hbox.add_child(volume_label)

	var checkbox = TextureButton.new()
	checkbox.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox.add_child(checkbox)
	
	match type:
		"master":
			master_volume_label = volume_label
			master_mute_checkbox = checkbox
			slider.value_changed.connect(func(new_value): Settings.master_volume = new_value)
			checkbox.pressed.connect(func(): Settings.master_muted = not Settings.master_muted)
		"music":
			music_volume_label = volume_label
			music_mute_checkbox = checkbox
			slider.value_changed.connect(func(new_value): Settings.music_volume = new_value)
			checkbox.pressed.connect(func(): Settings.music_muted = not Settings.music_muted)
		"sfx":
			sfx_volume_label = volume_label
			sfx_mute_checkbox = checkbox
			slider.value_changed.connect(func(new_value): Settings.sfx_volume = new_value)
			checkbox.pressed.connect(func(): Settings.sfx_muted = not Settings.sfx_muted)
	
	return hbox

func _update_checkbox_texture(button_ref: TextureButton, is_muted: bool):
	var new_texture = load(AssetPaths.SPRITE_CHECKBOX_UNCHECKED)
	if is_muted:
		new_texture = load(AssetPaths.SPRITE_CHECKBOX_CHECKED)
	
	if button_ref.texture_normal != new_texture:
		button_ref.texture_normal = new_texture

func _on_back_button_pressed():
	SceneManager.go_to_scene(AssetPaths.SCENE_OPTIONS_MENU)
