# src/core/sequencing/sequence_handle.gd
## A handle representing a running sequence.
##
## Allows for safe cancellation and emits a signal when the sequence is
## completed or cancelled.
class_name SequenceHandle
extends RefCounted

# --- Signals ---
## Emitted when the sequence finishes or is cancelled.
signal finished

# --- Member Variables ---
var is_running: bool = true

# --- Public Methods ---


## Cancels the execution of the associated sequence.
func cancel() -> void:
	if is_running:
		is_running = false
		finished.emit()
