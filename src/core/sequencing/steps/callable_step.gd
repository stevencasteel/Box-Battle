# src/core/sequencing/steps/callable_step.gd
# A sequence step that calls a Callable.
@tool
class_name CallableStep
extends SequenceStep

@export var callable: Callable

# MODIFIED: The function signature is now async.
func execute(_sequencer_node: Node) -> Variant:
	if callable.is_valid():
		# CORRECTED: We now `await` the result of the call.
		# If the function is normal, it returns instantly.
		# If the function is async, it waits for it to complete.
		var result = await callable.call()
		
		# If the function itself returns ANOTHER awaitable (like a Signal),
		# we pass it up to the sequencer to be awaited as well.
		if result is Signal or (typeof(result) == TYPE_OBJECT and result.has_method("is_valid")):
			return result
	else:
		push_warning("CallableStep: 'callable' is not set or is invalid.")
	
	return null