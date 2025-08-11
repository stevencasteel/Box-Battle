# src/ui/components/custom_slider/custom_slider.gd
#
# A self-contained, reusable custom slider component.
extends TextureRect

signal value_changed(value)

var knob: TextureRect
var is_dragging = false
var min_x = 0.0
var max_x = 0.0
var drag_offset = 0.0
var _initial_value = -1.0

func _ready():
	self.texture = load(AssetPaths.SPRITE_SLIDER_TRACK)
	
	knob = TextureRect.new()
	knob.texture = load(AssetPaths.SPRITE_SLIDER_KNOB)
	add_child(knob)
	
	knob.mouse_entered.connect(_on_knob_mouse_entered)
	knob.mouse_exited.connect(_on_knob_mouse_exited)
	
	# THE FIX: Wait for the next frame. This ensures any parent containers
	# have finished arranging their children before we calculate our bounds.
	await get_tree().process_frame
	
	knob.position.y = (size.y - knob.size.y) / 2
	min_x = global_position.x
	max_x = global_position.x + size.x - knob.size.x
	
	if _initial_value >= 0.0:
		var new_x_pos = min_x + (max_x - min_x) * _initial_value
		knob.global_position.x = clamp(new_x_pos, min_x, max_x)

func set_value(initial_value: float):
	_initial_value = initial_value

func _process(_delta):
	if is_dragging:
		var global_mouse_pos = get_global_mouse_position()
		knob.global_position.x = clamp(global_mouse_pos.x - drag_offset, min_x, max_x)
		
		if (max_x - min_x) > 0:
			var current_value = (knob.global_position.x - min_x) / (max_x - min_x)
			emit_signal("value_changed", current_value)

func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var knob_rect = knob.get_global_rect()
		
		if event.is_pressed():
			if knob_rect.has_point(event.global_position):
				is_dragging = true
				drag_offset = event.global_position.x - knob.global_position.x
		else:
			is_dragging = false
			if not knob_rect.has_point(get_global_mouse_position()):
				CursorManager.set_pointer_state(false)
			drag_offset = 0.0

func _on_knob_mouse_entered():
	CursorManager.set_pointer_state(true)

func _on_knob_mouse_exited():
	if not is_dragging:
		CursorManager.set_pointer_state(false)