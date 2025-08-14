# src/scenes/game_over/game_over_screen.gd
@tool
extends Control

const MenuManagerScript = preload(AssetPaths.SCRIPT_MENU_MANAGER)

@onready var back_button: StyledMenuItem = %BackButton

func _ready():
	if not Engine.is_editor_hint():
		back_button.text = "BACK"
		back_button.pressed.connect(_on_back_button_pressed)
		
		var menu_manager = MenuManagerScript.new()
		add_child(menu_manager)
		menu_manager.setup_menu([back_button])
		
		await get_tree().process_frame
		back_button.grab_focus()
	else:
		back_button.text = "BACK"

func _on_back_button_pressed():
	SceneManager.go_to_scene(AssetPaths.SCENE_TITLE_SCREEN)
