# src/core/sequencing/steps/callable_step.gd
@tool
## A sequence step that executes a [Callable].
class_name CallableStep
extends SequenceStep

# --- Editor Properties ---
@export var callable: Callable

# --- Virtual Methods ---


func execute(_sequencer_node: Node) -> Variant:
	if callable.is_valid():
		# Await the result of the call. If the function is async, this will
		# pause the sequence until it completes.
		var result = await callable.call()
		# If the function itself returns ANOTHER awaitable (like a Signal),
		# return it to the sequencer to be awaited as well.
		if result is Signal or (typeof(result) == TYPE_OBJECT and result.has_method("is_valid")):
			return result
	else:
		push_warning("CallableStep: 'callable' is not set or is invalid.")

	return null
