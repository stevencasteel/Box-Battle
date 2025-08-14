# src/scenes/dev/test_title_screen.gd
# REFACTORED: This version uses a clean, hierarchical container system
# for a much simpler and more robust layout.
extends Control

const StyledMenuItemScene = preload(AssetPaths.SCENE_STYLED_MENU_ITEM)
const MenuManagerScript = preload(AssetPaths.SCRIPT_MENU_MANAGER)
const LogoDisplayScene = preload(AssetPaths.SCENE_LOGO_DISPLAY)

func _ready():
	print("New Test Title Screen Initialized.")

	var bg = ColorRect.new()
	bg.color = Palette.COLOR_BACKGROUND
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)

	var main_vbox = VBoxContainer.new()
	main_vbox.set_anchors_preset(Control.PRESET_CENTER)
	main_vbox.grow_horizontal = Control.GROW_DIRECTION_BOTH
	main_vbox.grow_vertical = Control.GROW_DIRECTION_BOTH
	add_child(main_vbox)

	var title_label = Label.new()
	title_label.text = "BOX BATTLE"
	title_label.add_theme_font_override("font", load(AssetPaths.FONT_BLACK))
	title_label.add_theme_font_size_override("font_size", 128)
	title_label.add_theme_color_override("font_color", Palette.COLOR_TEXT_HEADER)
	title_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

	var menu_items_vbox = VBoxContainer.new()
	menu_items_vbox.alignment = VBoxContainer.ALIGNMENT_CENTER
	var start_button = StyledMenuItemScene.instantiate(); start_button.text = "START GAME"
	var options_button = StyledMenuItemScene.instantiate(); options_button.text = "OPTIONS"
	var exit_button = StyledMenuItemScene.instantiate(); exit_button.text = "EXIT"
	
	# SETTING 1: To increase space between OPTIONS and EXIT, change this value.
	exit_button.add_theme_constant_override("margin_top", 80)
	
	menu_items_vbox.add_child(start_button)
	menu_items_vbox.add_child(options_button)
	menu_items_vbox.add_child(exit_button)

	var footer_hbox = HBoxContainer.new()
	footer_hbox.alignment = HBoxContainer.ALIGNMENT_CENTER
	footer_hbox.add_theme_constant_override("separation", 50)
	var newgrounds_logo = LogoDisplayScene.instantiate(); newgrounds_logo.texture = load(AssetPaths.SPRITE_LOGO_NEWGROUNDS)
	var godot_logo = LogoDisplayScene.instantiate(); godot_logo.texture = load(AssetPaths.SPRITE_LOGO_GODOT)
	var itch_logo = LogoDisplayScene.instantiate(); itch_logo.texture = load(AssetPaths.SPRITE_LOGO_ITCH)
	footer_hbox.add_child(newgrounds_logo)
	footer_hbox.add_child(godot_logo)
	footer_hbox.add_child(itch_logo)

	# --- Add sections to the main container and SET SPACING ---
	
	# Set top padding to 0 as requested
	var top_spacer = Control.new(); top_spacer.custom_minimum_size.y = 0
	main_vbox.add_child(top_spacer)
	
	main_vbox.add_child(title_label)
	
	var title_menu_spacer = Control.new(); title_menu_spacer.custom_minimum_size.y = 20
	main_vbox.add_child(title_menu_spacer)
	
	main_vbox.add_child(menu_items_vbox)
	
	var expand_spacer = Control.new(); expand_spacer.size_flags_vertical = Control.SIZE_EXPAND_FILL
	main_vbox.add_child(expand_spacer)

	main_vbox.add_child(footer_hbox)
	
	# SETTING 2: To increase space between EXIT and the LOGOS, increase this value.
	# This adds padding to the bottom of the screen, pushing the logos up.
	var bottom_spacer = Control.new(); bottom_spacer.custom_minimum_size.y = 50
	main_vbox.add_child(bottom_spacer)
	
	menu_items_vbox.add_theme_constant_override("separation", 35)

	# --- Menu Manager Setup ---
	start_button.pressed.connect(_on_start_button_pressed)
	options_button.pressed.connect(_on_options_button_pressed)
	exit_button.pressed.connect(_on_exit_button_pressed)
	
	var menu_manager = MenuManagerScript.new()
	add_child(menu_manager)

	var menu_items: Array[Control] = [start_button, options_button, exit_button]
	menu_manager.setup_menu(menu_items)
	
	await get_tree().process_frame
	start_button.grab_focus()

# --- Signal Handlers ---
func _on_start_button_pressed():
	print("Start Button Pressed")

func _on_options_button_pressed():
	print("Options Button Pressed")

func _on_exit_button_pressed():
	print("Exit Button Pressed")
	get_tree().quit()
