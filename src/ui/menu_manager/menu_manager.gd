# src/ui/menu_manager/menu_manager.gd
#
# A reusable script for creating keyboard and mouse-navigable menus. An instance
# of this is created by each menu scene to manage its own set of buttons.
extends Node

# --- Inner Class: MenuItem ---
# A simple data structure to bundle a button node with its "type" (for sounds).
class MenuItem:
	var button: TextureButton
	var type: String

	func _init(btn: TextureButton, btn_type: String):
		self.button = btn
		self.type = btn_type

# --- Variables ---
var menu_items = []
var current_selection = 0
var cursor_left: TextureRect
var cursor_right: TextureRect

func _ready():
	# Create the cursor sprites using the safe path from AssetPaths.
	cursor_left = TextureRect.new()
	cursor_left.texture = load(AssetPaths.SPRITE_MENU_CURSOR)
	cursor_left.flip_h = true # Point it inwards.
	add_child(cursor_left)

	cursor_right = TextureRect.new()
	cursor_right.texture = load(AssetPaths.SPRITE_MENU_CURSOR)
	add_child(cursor_right)

	cursor_left.visible = false
	cursor_right.visible = false

# The main setup function, called by the parent menu scene.
func setup_menu(items: Array):
	menu_items = items
	if menu_items.is_empty(): return

	for i in range(menu_items.size()):
		var menu_item = menu_items[i]
		# Connect signals for each button.
		# When the mouse enters a button, we call our own function to handle it.
		menu_item.button.mouse_entered.connect(_on_mouse_entered.bind(i))
		# When the mouse leaves, we tell the cursor manager to reset the cursor state.
		menu_item.button.mouse_exited.connect(CursorManager.set_pointer_state.bind(false))
		# When the button is pressed (by click or keyboard), we handle the sound.
		menu_item.button.pressed.connect(_on_item_pressed.bind(i))

	# Set the initial selection to the first item.
	current_selection = 0
	# Wait one frame to ensure all buttons have their positions calculated.
	await get_tree().process_frame
	# Now update the cursors to point to the first item.
	_update_cursors()
	cursor_left.visible = true
	cursor_right.visible = true

# Catches unhandled input for keyboard/controller navigation.
func _unhandled_input(event):
	if event.is_action_pressed("ui_down"):
		_change_selection(1)
	elif event.is_action_pressed("ui_up"):
		_change_selection(-1)
	elif event.is_action_pressed("ui_accept"):
		if not menu_items.is_empty():
			menu_items[current_selection].button.emit_signal("pressed")

# Plays context-specific sounds based on the button type.
func _on_item_pressed(index: int):
	if index < 0 or index >= menu_items.size(): return

	var item_type = menu_items[index].type
	match item_type:
		"BACK":
			AudioManager.play_sfx(AssetPaths.AUDIO_SFX_MENU_BACK)
		"START":
			AudioManager.play_sfx(AssetPaths.AUDIO_SFX_START_CHIME)
		_: # Default case for "SELECT" or any other type.
			AudioManager.play_sfx(AssetPaths.AUDIO_SFX_MENU_SELECT)

# Handles the logic for changing the selected item via keyboard.
func _change_selection(amount: int):
	if menu_items.size() <= 1:
		AudioManager.play_sfx(AssetPaths.AUDIO_SFX_MENU_ERROR)
		return

	var new_selection = (current_selection + amount + menu_items.size()) % menu_items.size()

	if new_selection != current_selection:
		current_selection = new_selection
		AudioManager.play_sfx(AssetPaths.AUDIO_SFX_MENU_MOVE)
		_update_cursors()
	else:
		# This case can happen if there's only one item.
		AudioManager.play_sfx(AssetPaths.AUDIO_SFX_MENU_ERROR)

# Called when the mouse pointer enters a button's collision shape.
func _on_mouse_entered(index: int):
	CursorManager.set_pointer_state(true)
	if current_selection != index:
		current_selection = index
		AudioManager.play_sfx(AssetPaths.AUDIO_SFX_MENU_MOVE)
		_update_cursors()

# Moves the visual cursors to frame the currently selected button.
func _update_cursors():
	if menu_items.is_empty(): return

	var selected_button = menu_items[current_selection].button
	var button_pos = selected_button.position
	var button_size = selected_button.size
	var cursor_padding = 40

	cursor_left.position.x = button_pos.x - cursor_left.size.x - cursor_padding
	cursor_left.position.y = button_pos.y + (button_size.y - cursor_left.size.y) / 2

	cursor_right.position.x = button_pos.x + button_size.x + cursor_padding
	cursor_right.position.y = button_pos.y + (button_size.y - cursor_right.size.y) / 2