# src/entities/components/telegraph_component.gd
# A self-contained, reusable component for displaying attack telegraphs.
# It shows a visual warning for a set duration, then emits a signal
# and destroys itself.
class_name TelegraphComponent
extends Node2D

signal telegraph_finished

@onready var visual: ColorRect = $Visual

# The main public function. Call this to start the telegraph process.
func start_telegraph(duration: float, p_size: Vector2, p_position: Vector2, p_color: Color):
	# Configure the visual warning's appearance.
	self.global_position = p_position
	visual.size = p_size
	visual.color = p_color
	# Center the ColorRect on the component's position.
	visual.position = -p_size / 2.0
	
	# Use a tween to handle the timing. A tween is a node that animates
	# properties, but it can also just be used as a flexible timer.
	var tween = create_tween()
	
	# Wait for the specified duration.
	await tween.tween_interval(duration).finished
	
	# After the wait, emit the signal and clean up.
	# We check if the node is still valid in case the parent was destroyed
	# during the telegraph.
	if is_instance_valid(self):
		telegraph_finished.emit()
		queue_free()
