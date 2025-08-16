# src/core/systems/cursor_manager.gd
## An autoloaded singleton that manages the game's custom "fake" cursor.
##
## This provides full control over the cursor's appearance and ensures it
## renders above all other UI and game elements.
extends CanvasLayer

# --- Constants ---
const CURSOR_DEFAULT = preload(AssetPaths.SPRITE_CURSOR_DEFAULT)
const CURSOR_POINTER = preload(AssetPaths.SPRITE_CURSOR_POINTER)

# --- Private Member Variables ---
var _cursor_sprite: TextureRect

# --- Godot Lifecycle Methods ---

func _ready() -> void:
	# A high layer number ensures the cursor renders above everything else.
	layer = 10
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	_cursor_sprite = TextureRect.new()
	_cursor_sprite.texture = CURSOR_DEFAULT
	# CRITICAL: This makes the cursor "click-through," so it never blocks
	# mouse events intended for UI elements underneath it.
	_cursor_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(_cursor_sprite)

func _process(_delta: float) -> void:
	# Sync the custom cursor's position to the real mouse position every frame.
	_cursor_sprite.position = get_viewport().get_mouse_position()

# --- Public Methods ---

## Sets the cursor's appearance (e.g., when hovering a button).
func set_pointer_state(is_pointing: bool) -> void:
	if is_pointing:
		_cursor_sprite.texture = CURSOR_POINTER
	else:
		_cursor_sprite.texture = CURSOR_DEFAULT