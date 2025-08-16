# src/ui/components/styled_menu_item/styled_menu_item.gd
@tool
## A reusable, procedurally-drawn menu item component.
##
## Handles its own drawing, state changes (hover, press, focus), input,
## and animations for a self-contained, highly configurable button.
class_name StyledMenuItem
extends Control

# --- Signals ---
## Emitted when the menu item is clicked or activated via keyboard.
signal pressed

# --- Editor Properties ---
@export var text: String = "Menu Item" : set = set_text
@export var font_size: int = 48 : set = set_font_size
@export var glow_size: float = 0.0 : set = set_glow_size
@export var glow_alpha: float = 0.0 : set = set_glow_alpha

# --- Member Variables ---
var is_hovered: bool = false
var is_pressed: bool = false
var is_selected: bool = false

# --- Private Member Variables ---
var _font: Font
var _active_tween: Tween

# --- Godot Lifecycle Methods ---

func _ready() -> void:
	_font = load(AssetPaths.FONT_MAIN_BOLD)
	focus_mode = FOCUS_ALL
	mouse_filter = MOUSE_FILTER_STOP

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	resized.connect(queue_redraw)
	focus_entered.connect(_on_focus_entered)
	focus_exited.connect(_on_focus_exited)

func _gui_input(event: InputEvent) -> void:
	if event.is_action_pressed("ui_accept") and has_focus():
		get_viewport().set_input_as_handled()
		AudioManager.play_sfx(AssetPaths.SFX_UI_SELECT)
		emit_signal("pressed")
		_show_keyboard_press_feedback()
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			is_pressed = true
			queue_redraw()
		elif is_pressed: # On release
			AudioManager.play_sfx(AssetPaths.SFX_UI_SELECT)
			emit_signal("pressed")
			is_pressed = false
			queue_redraw()

func _draw() -> void:
	var bg_color: Color
	var text_color: Color
	var border_color: Color
	var border_width: float = 3.0

	if is_pressed:
		bg_color = Palette.get_color(2)
		text_color = Palette.COLOR_TEXT_PRIMARY
		border_color = Palette.COLOR_UI_ACCENT_PRIMARY
	elif is_hovered or is_selected:
		bg_color = Palette.COLOR_UI_ACCENT_PRIMARY
		text_color = Palette.COLOR_BACKGROUND
		border_color = Palette.get_color(4)
	else:
		bg_color = Palette.COLOR_UI_PANEL_BG
		text_color = Palette.COLOR_TEXT_PRIMARY
		border_color = Palette.COLOR_UI_ACCENT_PRIMARY

	if (is_hovered or is_selected) and glow_size > 0.0 and glow_alpha > 0.0:
		var glow_base_color = Palette.COLOR_UI_GLOW
		var final_glow_color = Color(glow_base_color.r, glow_base_color.g, glow_base_color.b, glow_alpha)
		var glow_rect = Rect2(Vector2.ZERO, size).grow(glow_size)
		draw_rect(glow_rect, final_glow_color)

	draw_rect(Rect2(Vector2.ZERO, size), bg_color)
	draw_rect(Rect2(Vector2.ZERO, size), border_color, false, border_width)

	var text_width = _font.get_string_size(text, HORIZONTAL_ALIGNMENT_CENTER, -1, font_size).x
	var text_pos_x = (size.x - text_width) / 2.0
	var text_pos_y = (size.y / 2.0) + (font_size / 3.0)
	draw_string(_font, Vector2(text_pos_x, text_pos_y), text, HORIZONTAL_ALIGNMENT_LEFT, -1, font_size, text_color)

# --- Public Setters ---

func set_text(new_text: String) -> void:
	if text != new_text:
		text = new_text
		queue_redraw()

func set_font_size(new_size: int) -> void:
	if font_size != new_size:
		font_size = new_size
		queue_redraw()

func set_glow_size(value: float) -> void:
	glow_size = value
	queue_redraw()

func set_glow_alpha(value: float) -> void:
	glow_alpha = value
	queue_redraw()

# --- Private Methods ---

func _show_keyboard_press_feedback() -> void:
	is_pressed = true
	queue_redraw()
	await get_tree().create_timer(0.1).timeout
	if is_instance_valid(self):
		is_pressed = false
		queue_redraw()

func _animate_selection(p_is_selected: bool) -> void:
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()

	_active_tween = create_tween().set_parallel(true)
	var target_glow_size = 28.0 if p_is_selected else 0.0
	var target_glow_alpha = 0.2 if p_is_selected else 0.0
	var duration = 0.3 if p_is_selected else 0.2

	_active_tween.tween_property(self, "glow_size", target_glow_size, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(self, "glow_alpha", target_glow_alpha, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)

# --- Signal Handlers ---

func _on_mouse_entered() -> void:
	is_hovered = true
	grab_focus()
	CursorManager.set_pointer_state(true)

func _on_mouse_exited() -> void:
	is_hovered = false
	if is_pressed:
		is_pressed = false
		queue_redraw()
	CursorManager.set_pointer_state(false)

func _on_focus_entered() -> void:
	is_selected = true
	_animate_selection(true)
	queue_redraw()

func _on_focus_exited() -> void:
	is_selected = false
	_animate_selection(false)
	queue_redraw()