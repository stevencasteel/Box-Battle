# src/ui/screens/sound_menu/sound_menu.gd
#
# Manages the sound settings screen, connecting UI elements to the global
# Settings singleton so changes are applied in real-time.
extends Control

const CustomSliderScript = preload(AssetPaths.SCRIPT_CUSTOM_SLIDER)
const MenuManager = preload(AssetPaths.SCRIPT_MENU_MANAGER)

# We need to store references to our UI elements to update them in _process
var master_volume_label: Label
var music_volume_label: Label
var sfx_volume_label: Label
var master_mute_checkbox: TextureButton
var music_mute_checkbox: TextureButton
var sfx_mute_checkbox: TextureButton

func _ready():
	EventBus.emit(EventCatalog.MENU_OPENED)
	var title_font = load(AssetPaths.FONT_BLACK)

	var title_label = Label.new()
	title_label.text = "Sound Settings"
	add_child(title_label)
	title_label.add_theme_font_override("font", title_font)
	title_label.add_theme_font_size_override("font_size", 80)
	title_label.size.x = get_viewport_rect().size.x
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.position.y = 80

	_create_volume_row("MASTER", 300, Settings.master_volume, "master")
	_create_volume_row("MUSIC", 450, Settings.music_volume, "music")
	_create_volume_row("SFX", 600, Settings.sfx_volume, "sfx")

	var back_button = TextureButton.new()
	back_button.texture_normal = load(AssetPaths.SPRITE_MENU_ITEM_BACK)
	add_child(back_button)
	back_button.position.x = (get_viewport_rect().size.x - back_button.size.x) / 2
	back_button.position.y = 800
	back_button.pressed.connect(_on_back_button_pressed)

	var menu = MenuManager.new()
	add_child(menu)
	menu.setup_menu([MenuManager.MenuItem.new(back_button, "BACK")])

func _exit_tree():
	EventBus.emit(EventCatalog.MENU_CLOSED)

func _process(_delta):
	# Sync volume labels
	master_volume_label.text = str(int(Settings.master_volume * 100))
	music_volume_label.text = str(int(Settings.music_volume * 100))
	sfx_volume_label.text = str(int(Settings.sfx_volume * 100))
	
	# Sync checkboxes
	_update_checkbox_texture(master_mute_checkbox, Settings.master_muted)
	_update_checkbox_texture(music_mute_checkbox, Settings.music_muted)
	_update_checkbox_texture(sfx_mute_checkbox, Settings.sfx_muted)

func _create_volume_row(label_text: String, y_pos: int, initial_volume: float, type: String):
	var row_label = Label.new()
	row_label.text = label_text
	add_child(row_label)
	row_label.add_theme_font_override("font", load(AssetPaths.FONT_BOLD))
	row_label.add_theme_font_size_override("font_size", 48)
	row_label.size.x = 250
	row_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	row_label.position = Vector2(40, y_pos)

	var slider = CustomSliderScript.new()
	add_child(slider)
	slider.set_value(initial_volume)
	slider.position = Vector2(300, y_pos + 25)

	var volume_label = Label.new()
	volume_label.add_theme_font_override("font", load(AssetPaths.FONT_REGULAR))
	volume_label.add_theme_font_size_override("font_size", 48)
	volume_label.size.x = 100
	volume_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	volume_label.position = Vector2(720, y_pos)
	add_child(volume_label)

	var checkbox = TextureButton.new()
	checkbox.position = Vector2(850, y_pos + 14)
	add_child(checkbox)
	
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

func _update_checkbox_texture(button_ref: TextureButton, is_muted: bool):
	var new_texture = load(AssetPaths.SPRITE_CHECKBOX_UNCHECKED)
	if is_muted:
		new_texture = load(AssetPaths.SPRITE_CHECKBOX_CHECKED)
	
	if button_ref.texture_normal != new_texture:
		button_ref.texture_normal = new_texture

func _on_back_button_pressed():
	get_tree().call_deferred("change_scene_to_file", AssetPaths.SCENE_OPTIONS_MENU)
