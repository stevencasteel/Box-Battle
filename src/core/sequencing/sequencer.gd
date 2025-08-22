# src/core/sequencing/sequencer.gd
## An autoloaded singleton that runs linear sequences of timed events.
##
## It is used for cinematic moments like boss intros. It tracks all active
## sequences and can safely cancel them, preventing errors during scene transitions.
extends Node

# --- Private Member Variables ---
var _active_handles: Array[SequenceHandle] = []

# --- Public Methods ---


## Executes a series of [SequenceStep] resources and returns a handle.
func run_sequence(steps: Array[SequenceStep]) -> SequenceHandle:
	var handle = SequenceHandle.new()
	_active_handles.append(handle)
	handle.finished.connect(_on_sequence_finished.bind(handle))

	_execute_sequence(steps, handle)
	return handle


## Immediately cancels all running sequences.
func cancel_all() -> void:
	# Iterate over a copy, as cancelling a handle modifies the original array.
	for handle in _active_handles.duplicate():
		handle.cancel()


# --- Private Methods ---


## The core async function that executes the sequence steps.
func _execute_sequence(steps: Array[SequenceStep], handle: SequenceHandle) -> void:
	if steps.is_empty():
		if handle.is_running:
			handle.is_running = false
			handle.finished.emit()
		return

	for step in steps:
		if not handle.is_running:
			return  # Stop if cancelled

		if not step is SequenceStep:
			push_warning("Sequencer: Invalid step found. Skipping.")
			continue

		var awaitable = await step.execute(self)
		if awaitable:
			await awaitable

	if handle.is_running:
		handle.is_running = false
		handle.finished.emit()


# --- Signal Handlers ---


## Cleans up a finished or cancelled sequence from the tracking array.
func _on_sequence_finished(handle_to_remove: SequenceHandle) -> void:
	var index = _active_handles.find(handle_to_remove)
	if index != -1:
		_active_handles.remove_at(index)
