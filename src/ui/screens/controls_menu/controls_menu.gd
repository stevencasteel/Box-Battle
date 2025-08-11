# src/ui/screens/controls_menu/controls_menu.gd
# Displays a static list of the game's controls using a layout that is
# pixel-perfect consistent with the Credits menu.
extends Control

const MenuManager = preload(AssetPaths.SCRIPT_MENU_MANAGER)

func _ready():
	EventBus.emit(EventCatalog.MENU_OPENED)
	
	# --- 1. Title (matches credits_menu.gd) ---
	var title_label = Label.new()
	title_label.text = "Controls"
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
	content_vbox.add_theme_constant_override("separation", 20)
	add_child(content_vbox)

	var controls_data = [
		{ "action": "Movement", "keys": "Arrow Keys / WASD" },
		{ "action": "Jump", "keys": "Space / X / Period" },
		{ "action": "Attack", "keys": "C / Comma" },
		{ "action": "Dash", "keys": "Z / Slash / Shift" },
		{ "action": "Pause / Menu", "keys": "Enter / P / Escape" },
		{ "action": "Back / Cancel", "keys": "Escape / Backspace" }
	]
	
	for data in controls_data:
		content_vbox.add_child(_create_control_row(data))

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

func _create_control_row(data: Dictionary) -> HBoxContainer:
	var hbox = HBoxContainer.new()
	hbox.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	hbox.add_theme_constant_override("separation", 40)
	
	var action_label = Label.new()
	action_label.text = data.action
	action_label.custom_minimum_size.x = 400
	action_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	action_label.add_theme_font_override("font", load(AssetPaths.FONT_BOLD))
	action_label.add_theme_font_size_override("font_size", 36)
	hbox.add_child(action_label)

	var keys_label = Label.new()
	keys_label.text = data.keys
	keys_label.custom_minimum_size.x = 500
	keys_label.add_theme_font_override("font", load(AssetPaths.FONT_REGULAR))
	keys_label.add_theme_font_size_override("font_size", 36)
	hbox.add_child(keys_label)
	
	return hbox

func _exit_tree():
	EventBus.emit(EventCatalog.MENU_CLOSED)

func _on_back_button_pressed():
	SceneManager.go_to_scene(AssetPaths.SCENE_OPTIONS_MENU)
