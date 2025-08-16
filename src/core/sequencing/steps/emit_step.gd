# src/core/sequencing/steps/emit_step.gd
@tool
## A sequence step that emits an event on the global [EventBus].
class_name EmitStep
extends SequenceStep

# --- Editor Properties ---
@export var event_name: StringName = &""
@export var payload: Variant = null

# --- Virtual Methods ---

func execute(_sequencer_node: Node) -> Variant:
	if event_name == &"":
		push_warning("EmitStep: 'event_name' is not set.")
		return null
	EventBus.emit(event_name, payload)
	return null