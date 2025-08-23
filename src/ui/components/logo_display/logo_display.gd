# src/ui/components/logo_display/logo_display.gd
@tool
## A reusable UI component for displaying an interactive logo.
##
## Provides visual feedback on hover and emits a signal when pressed.
class_name LogoDisplay
extends Control

# --- Signals ---
## Emitted when the logo is clicked, passing its [member logo_name].
signal pressed(logo_name: String)

# --- Node References ---
@onready var texture_rect: TextureRect = $TextureRect

# --- Editor Properties ---
@export var texture: Texture2D:
	set(value):
		texture = value
		if is_instance_valid(texture_rect):
			texture_rect.texture = texture

@export var logo_name: String = "Logo"
@export var glow_size: float = 0.0:
	set = set_glow_size
@export var glow_alpha: float = 0.0:
	set = set_glow_alpha

# --- Member Variables ---
var is_hovered: bool = false
var is_pressed: bool = false

# --- Private Member Variables ---
var _active_tween: Tween

# --- Godot Lifecycle Methods ---


func _ready() -> void:
	mouse_filter = MOUSE_FILTER_STOP

	if is_instance_valid(texture_rect) and texture:
		texture_rect.texture = texture

	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			is_pressed = true
			queue_redraw()
		elif is_pressed:  # On release
			emit_signal("pressed", logo_name)
			is_pressed = false
			queue_redraw()


func _draw() -> void:
	if is_hovered and glow_size > 0.0 and glow_alpha > 0.0:
		var glow_base_color = Palette.COLOR_UI_GLOW
		var final_glow_color = Color(
			glow_base_color.r, glow_base_color.g, glow_base_color.b, glow_alpha
		)
		var glow_rect = Rect2(Vector2.ZERO, size).grow(glow_size)
		draw_rect(glow_rect, final_glow_color)


# --- Public Setters ---


func set_glow_size(value: float) -> void:
	glow_size = value
	queue_redraw()


func set_glow_alpha(value: float) -> void:
	glow_alpha = value
	queue_redraw()


# --- Private Methods ---


func _animate_hover(p_is_hovered: bool) -> void:
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()

	_active_tween = create_tween().set_parallel(true)
	var target_glow_size = 20.0 if p_is_hovered else 0.0
	var target_glow_alpha = 0.2 if p_is_hovered else 0.0
	var duration = 0.3 if p_is_hovered else 0.2

	(
		_active_tween
		. tween_property(self, "glow_size", target_glow_size, duration)
		. set_trans(Tween.TRANS_SINE)
		. set_ease(Tween.EASE_OUT)
	)
	(
		_active_tween
		. tween_property(self, "glow_alpha", target_glow_alpha, duration)
		. set_trans(Tween.TRANS_SINE)
		. set_ease(Tween.EASE_OUT)
	)


# --- Signal Handlers ---


func _on_mouse_entered() -> void:
	is_hovered = true
	_animate_hover(true)
	if not Engine.is_editor_hint():
		CursorManager.set_pointer_state(true)
		AudioManager.play_sfx(AssetPaths.SFX_UI_MOVE)


func _on_mouse_exited() -> void:
	is_hovered = false
	if is_pressed:
		is_pressed = false
		queue_redraw()
	_animate_hover(false)
	if not Engine.is_editor_hint():
		CursorManager.set_pointer_state(false)