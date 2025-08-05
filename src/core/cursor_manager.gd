# src/core/cursor_manager.gd
#
# This singleton manages the game's custom "fake" cursor, giving us full
# control over its appearance on all platforms. It draws on a high layer
# to ensure it's always on top of other UI and game elements.
extends CanvasLayer

var cursor_sprite: TextureRect

# We preload our cursor images using the AssetPaths singleton for safety and clarity.
const CURSOR_DEFAULT = preload(AssetPaths.SPRITE_CURSOR_DEFAULT)
const CURSOR_POINTER = preload(AssetPaths.SPRITE_CURSOR_POINTER)

func _ready():
	# A high layer number ensures the cursor renders above everything else.
	layer = 10
	# Hide the computer's default mouse cursor.
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)

	cursor_sprite = TextureRect.new()
	cursor_sprite.texture = CURSOR_DEFAULT

	# CRITICAL: This makes our cursor sprite "click-through," so it never
	# blocks mouse events intended for buttons or objects underneath it.
	cursor_sprite.mouse_filter = Control.MOUSE_FILTER_IGNORE

	add_child(cursor_sprite)

func _process(_delta):
	# On every frame, our custom cursor's position is synced to the real mouse position.
	cursor_sprite.position = get_viewport().get_mouse_position()

# Public function to change the cursor's appearance (e.g., when hovering a button).
func set_pointer_state(is_pointing: bool):
	if is_pointing:
		cursor_sprite.texture = CURSOR_POINTER
	else:
		cursor_sprite.texture = CURSOR_DEFAULT