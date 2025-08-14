# src/scenes/dev/gui_title_screen.gd
# This script configures the layout and logic for the nodes defined in the .tscn file.
extends Control

const MenuManagerScript = preload(AssetPaths.SCRIPT_MENU_MANAGER)

# Get references to the nodes from the scene tree
@onready var background_color: ColorRect = $BackgroundColor
@onready var start_button: StyledMenuItem = %StartButton
@onready var options_button: StyledMenuItem = %OptionsButton
@onready var exit_button: StyledMenuItem = %ExitButton
@onready var newgrounds_logo: LogoDisplay = %NewgroundsLogo
@onready var godot_logo: LogoDisplay = %GodotLogo
@onready var itch_logo: LogoDisplay = %ItchLogo

func _ready():
	# --- Configure elements that need runtime setup ---
	background_color.color = Palette.COLOR_BACKGROUND
	
	start_button.text = "START GAME"
	options_button.text = "OPTIONS"
	exit_button.text = "EXIT"

	# --- Connect signals and set up navigation logic ---
	start_button.pressed.connect(func(): print("Start Pressed"))
	options_button.pressed.connect(func(): print("Options Pressed"))
	exit_button.pressed.connect(get_tree().quit)
	
	newgrounds_logo.pressed.connect(_on_logo_pressed)
	godot_logo.pressed.connect(_on_logo_pressed)
	itch_logo.pressed.connect(_on_logo_pressed)
	
	var menu_manager = MenuManagerScript.new()
	add_child(menu_manager)
	var menu_items: Array[Control] = [start_button, options_button, exit_button]
	menu_manager.setup_menu(menu_items)
	
	await get_tree().process_frame
	start_button.grab_focus()

func _on_logo_pressed(logo_name: String):
	print("%s Pressed" % logo_name)