# src/ui/components/custom_slider/custom_slider.gd
@tool
## A self-contained, reusable custom slider component.
extends TextureRect

# --- Signals ---
## Emitted when the slider's value changes.
signal value_changed(value: float)

# --- Member Variables ---
var knob: TextureRect
var is_dragging: bool = false
var min_x_pos: float = 0.0
var max_x_pos: float = 0.0
var drag_offset: float = 0.0
var _initial_value: float = -1.0 # Used to set value before node is ready

# --- Godot Lifecycle Methods ---

func _ready() -> void:
	self.texture = load(AssetPaths.SPRITE_SLIDER_TRACK)

	knob = TextureRect.new()
	knob.texture = load(AssetPaths.SPRITE_SLIDER_KNOB)
	add_child(knob)

	knob.mouse_entered.connect(_on_knob_mouse_entered)
	knob.mouse_exited.connect(_on_knob_mouse_exited)

	# Wait for the next frame to ensure parent containers have arranged children.
	await get_tree().process_frame

	knob.position.y = (size.y - knob.size.y) / 2.0
	min_x_pos = global_position.x
	max_x_pos = global_position.x + size.x - knob.size.x

	if _initial_value >= 0.0:
		var new_x_pos = min_x_pos + (max_x_pos - min_x_pos) * _initial_value
		knob.global_position.x = clamp(new_x_pos, min_x_pos, max_x_pos)

func _process(_delta: float) -> void:
	if is_dragging:
		var global_mouse_pos = get_global_mouse_position()
		knob.global_position.x = clamp(global_mouse_pos.x - drag_offset, min_x_pos, max_x_pos)

		if (max_x_pos - min_x_pos) > 0:
			var current_value = (knob.global_position.x - min_x_pos) / (max_x_pos - min_x_pos)
			emit_signal("value_changed", current_value)

func _gui_input(event: InputEvent) -> void:
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

# --- Public Methods ---

## Sets the initial value of the slider.
func set_value(initial_value: float) -> void:
	_initial_value = initial_value

# --- Signal Handlers ---

func _on_knob_mouse_entered() -> void:
	CursorManager.set_pointer_state(true)

func _on_knob_mouse_exited() -> void:
	if not is_dragging:
		CursorManager.set_pointer_state(false)