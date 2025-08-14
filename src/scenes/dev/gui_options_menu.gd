# src/scenes/dev/gui_options_menu.gd
extends Control

const MenuManagerScript = preload(AssetPaths.SCRIPT_MENU_MANAGER)

# THE FIX: Removed the incorrect @onready var for CreditsLabelContainer.
# These are the only nodes this script needs to know about.
@onready var sound_button: StyledMenuItem = %SoundButton
@onready var controls_button: StyledMenuItem = %ControlsButton
@onready var credits_button: StyledMenuItem = %CreditsButton
@onready var back_button: StyledMenuItem = %BackButton

func _ready():
	sound_button.text = "SOUND"
	controls_button.text = "CONTROLS"
	credits_button.text = "CREDITS"
	back_button.text = "BACK"
	
	sound_button.pressed.connect(_on_sound_button_pressed)
	controls_button.pressed.connect(_on_controls_button_pressed)
	credits_button.pressed.connect(_on_credits_button_pressed)
	back_button.pressed.connect(_on_back_button_pressed)
	
	var menu_manager = MenuManagerScript.new()
	add_child(menu_manager)
	
	var menu_items: Array[Control] = [sound_button, controls_button, credits_button, back_button]
	menu_manager.setup_menu(menu_items)
	
	await get_tree().process_frame
	sound_button.grab_focus()

func _on_sound_button_pressed():
	SceneManager.go_to_scene(AssetPaths.SCENE_GUI_SOUND_MENU)

func _on_controls_button_pressed():
	SceneManager.go_to_scene(AssetPaths.SCENE_GUI_CONTROLS_MENU)

func _on_credits_button_pressed():
	SceneManager.go_to_scene(AssetPaths.SCENE_GUI_CREDITS_MENU)

func _on_back_button_pressed():
	SceneManager.go_to_scene(AssetPaths.SCENE_GUI_TITLE_SCREEN)
