# src/ui/screens/victory_screen/victory_screen.gd
# This screen is shown when the player defeats the boss.
extends Control

@onready var return_button: TextureButton = $VBoxContainer/ReturnButton

const MenuManager = preload(AssetPaths.SCRIPT_MENU_MANAGER)

func _ready():
	return_button.texture_normal = load(AssetPaths.SPRITE_MENU_ITEM_BACK)
	return_button.pressed.connect(_on_return_button_pressed)

	var menu = MenuManager.new()
	add_child(menu)
	menu.setup_menu([MenuManager.MenuItem.new(return_button, "BACK")])

func _on_return_button_pressed():
	# MODIFIED: Use the new SceneManager.
	SceneManager.go_to_title_screen()