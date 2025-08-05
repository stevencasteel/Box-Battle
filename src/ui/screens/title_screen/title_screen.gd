# src/ui/screens/title_screen/title_screen.gd
#
# This script controls the main title screen. It displays the game title, menu
# buttons, plays the title music, and sets up menu navigation.
extends Control

# Preload the MenuManager script using the safe path from AssetPaths.
const MenuManager = preload(AssetPaths.SCRIPT_MENU_MANAGER)

func _ready():
	# Wait one frame to ensure singletons like AudioManager are fully ready.
	await get_tree().process_frame
	AudioManager.play_music(AssetPaths.AUDIO_MUSIC_TITLE)

	# --- Create UI Elements ---
	var title_graphic = TextureRect.new()
	title_graphic.texture = load(AssetPaths.SPRITE_TITLE)
	add_child(title_graphic)
	# Center the graphic horizontally.
	title_graphic.position = Vector2((get_viewport_rect().size.x - title_graphic.size.x) / 2, 220)

	var start_button = TextureButton.new()
	start_button.texture_normal = load(AssetPaths.SPRITE_MENU_ITEM_START)
	add_child(start_button)
	start_button.position = Vector2((get_viewport_rect().size.x - start_button.size.x) / 2, 450)

	var options_button = TextureButton.new()
	options_button.texture_normal = load(AssetPaths.SPRITE_MENU_ITEM_OPTIONS)
	add_child(options_button)
	options_button.position = Vector2((get_viewport_rect().size.x - options_button.size.x) / 2, 600)

	# --- Connect Signals ---
	start_button.pressed.connect(_on_start_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)

	# --- Initialize Menu Navigation ---
	var menu = MenuManager.new()
	add_child(menu)
	
	var menu_items = [
		MenuManager.MenuItem.new(start_button, "START"),
		MenuManager.MenuItem.new(options_button, "SELECT")
	]
	menu.setup_menu(menu_items)

# --- Signal Handler Functions ---

func _on_start_button_pressed():
	# Use AssetPaths to safely change to the gameplay scene.
	get_tree().call_deferred("change_scene_to_file", AssetPaths.SCENE_GAME)

func _on_options_button_pressed():
	# Use AssetPaths to safely change to the options menu.
	get_tree().call_deferred("change_scene_to_file", AssetPaths.SCENE_OPTIONS_MENU)