# src/core/sequencing/sequencer.gd
#
# An autoloaded singleton that runs sequences of timed events. It now
# correctly signals completion via the SequenceHandle.
extends Node

func run_sequence(steps: Array[SequenceStep]) -> SequenceHandle:
	var handle = SequenceHandle.new()
	_execute_sequence(steps, handle)
	return handle

func _execute_sequence(steps: Array[SequenceStep], handle: SequenceHandle) -> void:
	if steps.is_empty():
		handle.is_running = false
		handle.finished.emit()
		return

	for step in steps:
		if not handle.is_running:
			# The handle.finished signal is emitted by cancel() in this case.
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
