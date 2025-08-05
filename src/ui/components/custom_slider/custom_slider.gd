# src/ui/components/custom_slider/custom_slider.gd
#
# A self-contained, reusable custom slider component. It emits a 'value_changed'
# signal that the parent menu (SoundMenu) listens for.
extends TextureRect

signal value_changed(value)

var knob: TextureRect
var is_dragging = false
var min_x = 0.0
var max_x = 0.0
var drag_offset = 0.0
var _initial_value = -1.0

func _ready():
	# Load textures using safe paths from the AssetPaths singleton.
	self.texture = load(AssetPaths.SPRITE_SLIDER_TRACK)
	
	knob = TextureRect.new()
	knob.texture = load(AssetPaths.SPRITE_SLIDER_KNOB)
	add_child(knob)
	
	# Connect signals for mouse interaction.
	knob.mouse_entered.connect(_on_knob_mouse_entered)
	knob.mouse_exited.connect(_on_knob_mouse_exited)
	
	# Wait for the node's size and position to be finalized before calculating bounds.
	await get_tree().process_frame
	
	knob.position.y = (size.y - knob.size.y) / 2
	min_x = global_position.x
	max_x = global_position.x + size.x - knob.size.x
	
	if _initial_value >= 0.0:
		var new_x_pos = min_x + (max_x - min_x) * _initial_value
		# 'clamp' ensures the value stays within the min/max range.
		knob.global_position.x = clamp(new_x_pos, min_x, max_x)

# Public function called by the Sound Menu to set the initial volume.
func set_value(initial_value: float):
	_initial_value = initial_value

func _process(_delta):
	# This code only runs if the user is actively dragging the knob.
	if is_dragging:
		var global_mouse_pos = get_global_mouse_position()
		# Move the knob to follow the mouse, but clamped within the slider's bounds.
		knob.global_position.x = clamp(global_mouse_pos.x - drag_offset, min_x, max_x)
		
		if (max_x - min_x) > 0:
			# Calculate the current value as a fraction (0.0 to 1.0).
			var current_value = (knob.global_position.x - min_x) / (max_x - min_x)
			# Emit our custom signal, sending the new value to the sound menu.
			emit_signal("value_changed", current_value)

# This function handles mouse clicks on the slider track.
func _gui_input(event):
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		var knob_rect = knob.get_global_rect()
		
		if event.is_pressed():
			# Check if the click was on the knob to initiate dragging.
			if knob_rect.has_point(event.global_position):
				is_dragging = true
				# Calculate offset to make dragging feel smooth and natural.
				drag_offset = event.global_position.x - knob.global_position.x
		else:
			# When the button is released, stop dragging.
			is_dragging = false
			# Reset the cursor if the mouse is no longer over the knob.
			if not knob_rect.has_point(get_global_mouse_position()):
				CursorManager.set_pointer_state(false)
			drag_offset = 0.0

func _on_knob_mouse_entered():
	CursorManager.set_pointer_state(true)

func _on_knob_mouse_exited():
	# Only reset the cursor if we are NOT currently dragging the knob.
	# This prevents the cursor from flickering while dragging.
	if not is_dragging:
		CursorManager.set_pointer_state(false)