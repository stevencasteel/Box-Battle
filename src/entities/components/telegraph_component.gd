# src/entities/components/telegraph_component.gd
@tool
## A self-contained, reusable component for displaying attack telegraphs.
##
## It shows a visual warning for a set duration, then emits a signal
## and automatically frees itself from the scene tree.
class_name TelegraphComponent
extends Node2D

# --- Signals ---
## Emitted when the telegraph's duration has finished.
signal telegraph_finished

# --- Node References ---
@onready var visual: ColorRect = $Visual

# --- Public Methods ---

## Configures and starts the telegraph visual and timer.
func start_telegraph(duration: float, p_size: Vector2, p_position: Vector2, p_color: Color) -> void:
	self.global_position = p_position
	visual.size = p_size
	visual.color = p_color
	# Center the ColorRect on the component's position.
	visual.position = -p_size / 2.0

	var tween = create_tween()
	await tween.tween_interval(duration).finished

	if is_instance_valid(self):
		telegraph_finished.emit()
		queue_free()