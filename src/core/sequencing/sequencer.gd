# src/core/sequencing/sequencer.gd
#
# An autoloaded singleton that runs sequences of timed events. It now tracks
# all active sequences and can safely cancel them all, preventing errors
# during scene transitions.
extends Node

var _active_handles: Array[SequenceHandle] = []

func run_sequence(steps: Array[SequenceStep]) -> SequenceHandle:
	var handle = SequenceHandle.new()
	
	# THE FIX: Track the new handle and connect to its finished signal for cleanup.
	_active_handles.append(handle)
	handle.finished.connect(_on_sequence_finished.bind(handle))
	
	_execute_sequence(steps, handle)
	return handle

# NEW: Public function to cancel all running sequences.
func cancel_all():
	print("VERIFICATION: Sequencer cancelling all active handles.")
	# Iterate over a copy, because cancelling a handle will modify the original array.
	for handle in _active_handles.duplicate():
		handle.cancel()

# NEW: Private handler to clean up finished sequences from the tracking array.
func _on_sequence_finished(handle_to_remove: SequenceHandle):
	var index = _active_handles.find(handle_to_remove)
	if index != -1:
		_active_handles.remove_at(index)

func _execute_sequence(steps: Array[SequenceStep], handle: SequenceHandle) -> void:
	if steps.is_empty():
		if handle.is_running:
			handle.is_running = false
			handle.finished.emit()
		return

	for step in steps:
		# THE FIX: Check if the sequence has been cancelled before executing the next step.
		if not handle.is_running:
			return

		if not step is SequenceStep:
			push_warning("Sequencer: Invalid step found. Skipping.")
			continue
		
		var awaitable = await step.execute(self)
		if awaitable:
			await awaitable
	
	if handle.is_running:
		handle.is_running = false
		handle.finished.emit()