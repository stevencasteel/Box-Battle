# src/ui/menu_manager/menu_manager.gd
## A helper node that manages keyboard navigation and cursor display for a menu.
##
## This is intended to be instanced by a menu scene at runtime. It handles
## focus changes and draws selection cursors next to the focused item.
extends Node

# --- Member Variables ---
var menu_items: Array[Control] = []
var current_selection_index: int = 0

var _cursor_left: ColorRect
var _cursor_right: ColorRect

# --- Godot Lifecycle Methods ---

func _ready() -> void:
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

func _unhandled_input(event: InputEvent) -> void:
	if menu_items.is_empty(): return

	if event.is_action_pressed("ui_down"):
		_change_selection(1)
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up"):
		_change_selection(-1)
		get_viewport().set_input_as_handled()

# --- Public Methods ---

## Initializes the manager with a list of menu items to control.
func setup_menu(items: Array[Control]) -> void:
	if items.is_empty(): return
	self.menu_items = items

	for item in menu_items:
		item.focus_entered.connect(_on_item_focused.bind(item))

# --- Private Methods ---

func _change_selection(amount: int) -> void:
	if menu_items.size() <= 1:
		AudioManager.play_sfx(AssetPaths.SFX_UI_ERROR)
		return

	var new_selection = (current_selection_index + amount + menu_items.size()) % menu_items.size()
	menu_items[new_selection].grab_focus()

func _update_cursors(selected_item: Control) -> void:
	await get_tree().process_frame # Wait for layout to settle

	if not is_instance_valid(selected_item): return

	var item_pos = selected_item.global_position
	var item_size = selected_item.size
	var cursor_padding = 40.0

	_cursor_left.global_position.y = item_pos.y + (item_size.y - _cursor_left.size.y) / 2.0
	_cursor_left.global_position.x = item_pos.x - cursor_padding - _cursor_left.size.x

	_cursor_right.global_position.y = item_pos.y + (item_size.y - _cursor_right.size.y) / 2.0
	_cursor_right.global_position.x = item_pos.x + item_size.x + cursor_padding

	_cursor_left.visible = true
	_cursor_right.visible = true

# --- Signal Handlers ---

func _on_item_focused(focused_item: Control) -> void:
	var index = menu_items.find(focused_item)
	if index != -1:
		current_selection_index = index

	_update_cursors(focused_item)
	AudioManager.play_sfx(AssetPaths.SFX_UI_MOVE)