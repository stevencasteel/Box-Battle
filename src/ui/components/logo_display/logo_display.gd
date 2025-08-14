@tool
class_name LogoDisplay
extends Control

signal pressed(logo_name)

@onready var texture_rect: TextureRect = $TextureRect

@export var texture: Texture2D:
	set(value):
		texture = value
		if is_instance_valid(texture_rect):
			texture_rect.texture = texture

@export var logo_name: String = "Logo"
@export var glow_size: float = 0.0 : set = set_glow_size
@export var glow_alpha: float = 0.0 : set = set_glow_alpha

var is_hovered: bool = false
var is_pressed: bool = false
var _active_tween: Tween

func _ready():
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
		else:
			if is_pressed:
				AudioManager.play_sfx(AssetPaths.AUDIO_SFX_MENU_SELECT)
				emit_signal("pressed", logo_name)
				is_pressed = false
				queue_redraw()

func _draw() -> void:
	if is_hovered and glow_size > 0.0 and glow_alpha > 0.0:
		var glow_base_color = Palette.COLOR_UI_GLOW
		var final_glow_color = Color(glow_base_color.r, glow_base_color.g, glow_base_color.b, glow_alpha)
		var glow_rect = Rect2(Vector2.ZERO, size).grow(glow_size)
		draw_rect(glow_rect, final_glow_color)

func set_glow_size(value: float):
	glow_size = value
	queue_redraw()

func set_glow_alpha(value: float):
	glow_alpha = value
	queue_redraw()

func _on_mouse_entered():
	is_hovered = true
	CursorManager.set_pointer_state(true)
	AudioManager.play_sfx(AssetPaths.AUDIO_SFX_MENU_MOVE)
	_animate_hover(true)

func _on_mouse_exited():
	is_hovered = false
	if is_pressed:
		is_pressed = false
		queue_redraw()
	CursorManager.set_pointer_state(false)
	_animate_hover(false)

func _animate_hover(p_is_hovered: bool):
	if _active_tween and _active_tween.is_valid():
		_active_tween.kill()
	
	_active_tween = create_tween().set_parallel(true)
	var target_glow_size = 20.0 if p_is_hovered else 0.0
	# THE FIX: Increased target alpha from 0.1 to 0.2
	var target_glow_alpha = 0.2 if p_is_hovered else 0.0
	var duration = 0.3 if p_is_hovered else 0.2
	
	_active_tween.tween_property(self, "glow_size", target_glow_size, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)
	_active_tween.tween_property(self, "glow_alpha", target_glow_alpha, duration).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT)