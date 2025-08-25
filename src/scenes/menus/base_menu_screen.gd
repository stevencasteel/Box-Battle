# src/scenes/menus/base_menu_screen.gd
## A base class for all menu screens to inherit from.
##
## It provides a standardized way to set up keyboard navigation via the
## MenuManager and handles common audio feedback for UI interactions.
class_name BaseMenuScreen
extends Control

# --- Constants ---
const MenuManagerScript = preload(AssetPaths.SCRIPT_MENU_MANAGER)

# --- Protected Methods (for child classes to use) ---

## Initializes the menu manager and connects common feedback signals.
## [param focusable_items]: An array of Controls that can be navigated with the keyboard.
## [param all_interactive_items]: An array of all Controls that should provide audio feedback.
func setup_menu_navigation(focusable_items: Array[Control], all_interactive_items: Array[Control]) -> void:
	if not Engine.is_editor_hint():
		var menu_manager = MenuManagerScript.new()
		add_child(menu_manager)
		menu_manager.setup_menu(focusable_items)
		menu_manager.selection_changed.connect(_on_any_item_focused)

		for item in all_interactive_items:
			if item.has_signal("pressed"):
				item.pressed.connect(_on_any_item_pressed)
			
			if item.has_signal("mouse_entered"):
				item.mouse_entered.connect(_on_any_item_focused)

		var credits_label: RichTextLabel = find_child("CreditsLabel", true, false)
		if is_instance_valid(credits_label):
			credits_label.meta_hover_started.connect(func(_meta): CursorManager.set_pointer_state(true))
			credits_label.meta_hover_ended.connect(func(_meta): CursorManager.set_pointer_state(false))
			credits_label.meta_clicked.connect(func(_meta): _on_any_item_pressed())
			# THE FIX: Use a lambda to absorb the 'meta' argument before calling the sound handler.
			credits_label.meta_hover_started.connect(func(_meta): _on_any_item_focused())

# --- Private Signal Handlers ---

func _on_any_item_pressed() -> void:
	AudioManager.play_sfx(AssetPaths.SFX_UI_SELECT)

func _on_any_item_focused() -> void:
	AudioManager.play_sfx(AssetPaths.SFX_UI_MOVE)