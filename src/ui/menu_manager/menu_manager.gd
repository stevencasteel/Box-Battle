# src/ui/menu_manager/menu_manager.gd
# MODIFIED: The manager now correctly handles single-item menus.
extends Node

var menu_items: Array[Control] = []
var current_selection = 0

var _cursor_left: ColorRect
var _cursor_right: ColorRect

func _ready():
	_cursor_left = ColorRect.new()
	_cursor_left.size = Vector2(20, 20)
	_cursor_left.color = Palette.COLOR_UI_ACCENT_PRIMARY
	_cursor_left.visible = false
	add_child(_cursor_left)

	_cursor_right = ColorRect.new()
	_cursor_right.size = Vector2(20, 20)
	_cursor_right.color = Palette.COLOR_UI_ACCENT_PRIMARY
	_cursor_right.visible = false
	add_child(_cursor_right)

func setup_menu(items: Array[Control]):
	if items.is_empty(): return
	self.menu_items = items
	
	for item in menu_items:
		item.focus_entered.connect(_on_item_focused.bind(item))

func _unhandled_input(event):
	if menu_items.is_empty(): return

	if event.is_action_pressed("ui_down"):
		_change_selection(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		_change_selection(-1)
		get_viewport().set_input_as_handled()

func _on_item_focused(focused_item: Control):
	var index = menu_items.find(focused_item)
	if index != -1:
		current_selection = index
	
	_update_cursors(focused_item)
	# THE FIX: Use the new constant name for the move sound effect.
	AudioManager.play_sfx(AssetPaths.SFX_UI_MOVE)

func _change_selection(amount: int):
	if menu_items.size() <= 1:
		# THE FIX: Use the new constant name for the error sound effect.
		AudioManager.play_sfx(AssetPaths.SFX_UI_ERROR)
		return

	var new_selection = (current_selection + amount + menu_items.size()) % menu_items.size()
	menu_items[new_selection].grab_focus()

func _update_cursors(selected_item: Control):
	await get_tree().process_frame
	
	if not is_instance_valid(selected_item): return
	
	var item_pos = selected_item.global_position
	var item_size = selected_item.size
	var cursor_padding = 40
	
	_cursor_left.global_position.y = item_pos.y + (item_size.y - _cursor_left.size.y) / 2
	_cursor_left.global_position.x = item_pos.x - cursor_padding - _cursor_left.size.x
	
	_cursor_right.global_position.y = item_pos.y + (item_size.y - _cursor_right.size.y) / 2
	_cursor_right.global_position.x = item_pos.x + item_size.x + cursor_padding
	
	_cursor_left.visible = true
	_cursor_right.visible = true
