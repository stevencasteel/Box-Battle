# src/core/sequencing/sequencer.gd
#
# An autoloaded singleton that runs sequences of timed events. This version now
# returns a SequenceHandle to allow for safe cancellation of running sequences.
extends Node

# The public API. Starts a sequence and immediately returns a handle to it.
func run_sequence(steps: Array[SequenceStep]) -> SequenceHandle:
	var handle = SequenceHandle.new()
	# Start the actual execution in the background, so this function can return instantly.
	_execute_sequence(steps, handle)
	return handle

# The private method that runs the sequence loop.
# MODIFIED: This function is now async.
func _execute_sequence(steps: Array[SequenceStep], handle: SequenceHandle) -> void:
	if steps.is_empty():
		handle.is_running = false
		return

	for step in steps:
		# CRITICAL: Before each step, check if the sequence has been cancelled.
		if not handle.is_running:
			return # Abort the sequence.

		if not step is SequenceStep:
			push_warning("Sequencer: Invalid step found (not a SequenceStep resource). Skipping.")
			continue
		
		# CORRECTED: We now `await` the execution of the step itself.
		# This handles both normal and async steps correctly.
		var awaitable = await step.execute(self)
		if awaitable:
			await awaitable
	
	# Once all steps are complete, mark the handle as no longer running.
	handle.is_running = false
