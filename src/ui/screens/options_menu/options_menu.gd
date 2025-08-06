# src/ui/screens/options_menu/options_menu.gd
#
# Manages the Options menu, which acts as a hub to navigate to other screens.
extends Control

const MenuManager = preload(AssetPaths.SCRIPT_MENU_MANAGER)

func _ready():
	var title_font = load(AssetPaths.FONT_BLACK)
	
	# --- Create UI Elements ---
	var title_label = Label.new()
	title_label.text = "Options"
	add_child(title_label)
	title_label.add_theme_font_override("font", title_font)
	title_label.add_theme_font_size_override("font_size", 96)
	title_label.size.x = get_viewport_rect().size.x
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title_label.position.y = 80
	
	var sound_button = TextureButton.new()
	sound_button.texture_normal = load(AssetPaths.SPRITE_MENU_ITEM_SOUND)
	add_child(sound_button)
	sound_button.position = Vector2((get_viewport_rect().size.x - sound_button.size.x) / 2, 300)
	
	var controls_button = TextureButton.new()
	controls_button.texture_normal = load(AssetPaths.SPRITE_MENU_ITEM_CONTROLS)
	add_child(controls_button)
	controls_button.position = Vector2((get_viewport_rect().size.x - controls_button.size.x) / 2, 450)

	var credits_button = TextureButton.new()
	credits_button.texture_normal = load(AssetPaths.SPRITE_MENU_ITEM_CREDITS)
	add_child(credits_button)
	credits_button.position = Vector2((get_viewport_rect().size.x - credits_button.size.x) / 2, 600)
	
	var back_button = TextureButton.new()
	back_button.texture_normal = load(AssetPaths.SPRITE_MENU_ITEM_BACK)
	add_child(back_button)
	back_button.position = Vector2((get_viewport_rect().size.x - back_button.size.x) / 2, 800)
	
	# --- Connect Signals ---
	sound_button.pressed.connect(_on_sound_button_pressed)
	controls_button.pressed.connect(_on_controls_button_pressed)
	credits_button.pressed.connect(_on_credits_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)
	
	# --- Initialize Menu Navigation ---
	var menu = MenuManager.new()
	add_child(menu)
	
	var menu_items = [
		MenuManager.MenuItem.new(sound_button, "SELECT"),
		MenuManager.MenuItem.new(controls_button, "SELECT"),
		MenuManager.MenuItem.new(credits_button, "SELECT"),
		MenuManager.MenuItem.new(back_button, "BACK")
	]
	menu.setup_menu(menu_items)

# --- Button Press Handlers ---

func _on_sound_button_pressed():
	get_tree().change_scene_to_file(AssetPaths.SCENE_SOUND_MENU)

func _on_controls_button_pressed():
	get_tree().change_scene_to_file(AssetPaths.SCENE_CONTROLS_MENU)

func _on_credits_button_pressed():
	get_tree().change_scene_to_file(AssetPaths.SCENE_CREDITS_MENU)

func _on_back_button_pressed():
	get_tree().change_scene_to_file(AssetPaths.SCENE_TITLE_SCREEN)