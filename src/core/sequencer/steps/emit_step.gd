# src/core/sequencer/steps/emit_step.gd
# A sequence step that emits an event on the global EventBus.
@tool
class_name EmitStep
extends SequenceStep

@export var event_name: StringName = &""
@export var payload: Variant = null

# CORRECTED: The function signature now returns '-> Variant' to match its parent,
# SequenceStep. Since this step completes instantly, it returns null.
func execute(_sequencer_node: Node) -> Variant:
	if event_name == &"":
		push_warning("EmitStep: 'event_name' is not set.")
		return null
	EventBus.emit(event_name, payload)
	return null
