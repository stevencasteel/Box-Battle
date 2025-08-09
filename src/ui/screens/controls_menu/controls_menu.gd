# src/ui/screens/controls_menu/controls_menu.gd
#
# Displays a static list of the game's controls.
extends Control

const MenuManager = preload(AssetPaths.SCRIPT_MENU_MANAGER)

func _ready():
	EventBus.emit(EventCatalog.MENU_OPENED)
	var title_font = load(AssetPaths.FONT_BLACK)
	var bold_font = load(AssetPaths.FONT_BOLD)
	var regular_font = load(AssetPaths.FONT_REGULAR)

	# --- Title ---
	var title_label = Label.new()
	title_label.text = "Controls"
	add_child(title_label)
	title_label.add_theme_font_override("font", title_font)
	title_label.add_theme_font_size_override("font_size", 96)
	title_label.size.x = get_viewport_rect().size.x
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.position.y = 80

	# --- Controls List ---
	var controls_data = [
		{ "action": "Movement", "keys": "Arrow Keys / WASD / Mouse" },
		{ "action": "Primary Action", "keys": "X / . / Space / Left-Click" },
		{ "action": "Secondary Action", "keys": "C / , / Shift / Right-Click" },
		{ "action": "Tertiary Action", "keys": "Z / / / Ctrl / Middle-Click" },
		{ "action": "Pause / Menu", "keys": "Enter / P / Escape" },
		{ "action": "Back / Cancel", "keys": "Escape / Backspace" }
	]

	var start_y = 300
	var item_gap = 70

	for i in range(controls_data.size()):
		var data = controls_data[i]
		var y_pos = start_y + i * item_gap

		var action_label = Label.new()
		action_label.text = data.action
		add_child(action_label)
		action_label.add_theme_font_override("font", bold_font)
		action_label.add_theme_font_size_override("font_size", 36)
		action_label.size.x = 390
		action_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
		action_label.position = Vector2(0, y_pos)

		var keys_label = Label.new()
		keys_label.text = data.keys
		add_child(keys_label)
		keys_label.add_theme_font_override("font", regular_font)
		keys_label.add_theme_font_size_override("font_size", 36)
		keys_label.position = Vector2(460, y_pos)

	# --- Back Button ---
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

func _on_back_button_pressed():
	get_tree().call_deferred("change_scene_to_file", AssetPaths.SCENE_OPTIONS_MENU)