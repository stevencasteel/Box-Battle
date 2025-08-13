# src/core/sequencing/sequence_handle.gd
#
# A handle that represents a running sequence. It allows for safe cancellation
# and emits a signal when the sequence is completed or cancelled.
class_name SequenceHandle
extends RefCounted

signal finished

var is_running: bool = true

func cancel() -> void:
	if is_running:
		is_running = false
		finished.emit() # Signal completion when cancelled.