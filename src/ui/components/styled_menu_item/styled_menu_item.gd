# src/ui/components/styled_menu_item/styled_menu_item.gd
#
# The core logic for our new, reusable, procedurally-drawn menu item.
# This component will be the cornerstone of our "Framer + Geometry Wars" UI.
# It extends Control and uses the _draw() function to render itself.
@tool
class_name StyledMenuItem
extends Control

# --- Animated Properties ---
# REMOVED: corner_radius is no longer needed.
@export var glow_size: float = 0.0 : set = set_glow_size
@export var glow_alpha: float = 0.0 : set = set_glow_alpha

# --- Properties ---
@export var text: String = "Menu Item" : set = set_text

# --- State ---
var is_hovered: bool = false
var is_pressed: bool = false
var is_selected: bool = false # For keyboard/controller navigation

# --- Internal References ---
var _font: Font
var _active_tween: Tween

func _ready() -> void:
	_font = load(AssetPaths.FONT_BOLD)
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)

# --- The Core Drawing Function ---
func _draw() -> void:
	# --- Step 1: Draw the Glow Effect ---
	if glow_size > 0.0 and glow_alpha > 0.0:
		_draw_glow()

	# --- Step 2: Draw the Main Button ---
	var bg_color: Color
	var text_color: Color
	var border_color: Color
	var border_width: float = 3.0

	if is_hovered or is_selected:
		bg_color = Palette.COLOR_UI_ACCENT_PRIMARY
		text_color = Palette.COLOR_BACKGROUND
		border_color = Palette.get_color(4)
	else:
		bg_color = Palette.COLOR_UI_PANEL_BG
		text_color = Palette.COLOR_TEXT_PRIMARY
		border_color = Palette.COLOR_UI_ACCENT_PRIMARY

	# REVERTED: Draw sharp rectangles for the background and border.
	draw_rect(Rect2(Vector2.ZERO, size), bg_color)
	draw_rect(Rect2(Vector2.ZERO, size), border_color, false, border_width)
	
	# --- Step 3: Draw the Text ---
	var font_size = 48
	var text_width = _font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size).x
	var text_pos_x = (size.x - text_width) / 2
	var text_pos_y = (size.y / 2) + (font_size / 3.0)
	draw_string(_font, Vector2(text_pos_x, text_pos_y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_color)

# --- Drawing Helpers ---
func _draw_glow() -> void:
	var glow_base_color = Palette.COLOR_UI_GLOW
	var final_glow_color = Color(glow_base_color.r, glow_base_color.g, glow_base_color.b, glow_alpha)
	var glow_rect = Rect2(Vector2.ZERO, size).grow(glow_size)
	
	# REVERTED: Draw a sharp rectangle for the glow.
	draw_rect(glow_rect, final_glow_color)

# REMOVED: The _draw_rounded_rect and _draw_rounded_rect_border functions are no longer needed.

# --- Property Setters ---
func set_text(new_text: String):
	if text != new_text:
		text = new_text
		queue_redraw()

# REMOVED: The set_corner_radius function is no longer needed.

func set_glow_size(value: float):
	glow_size = value
	queue_redraw()

func set_glow_alpha(value: float):
	glow_alpha = value
	queue_redraw()

# --- Signal Handlers ---
func _on_mouse_entered() -> void:
	is_hovered = true
	CursorManager.set_pointer_state(true)
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	
	_active_tween = create_tween().set_parallel(true)
	_active_tween.tween_property(self, "glow_size", 28.0, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(self, "glow_alpha", 0.1, 0.3).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

func _on_mouse_exited() -> void:
	is_hovered = false
	CursorManager.set_pointer_state(false)
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
		
	_active_tween = create_tween().set_parallel(true)
	_active_tween.tween_property(self, "glow_size", 0.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(self, "glow_alpha", 0.0, 0.2).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
