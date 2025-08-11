# src/core/sequencing/sequence_handle.gd
#
# A handle that represents a running sequence. This allows the calling code
# to interact with the sequence after it has been started, primarily to cancel it.
class_name SequenceHandle
extends RefCounted

var is_running: bool = true

func cancel() -> void:
	if is_running:
		print("VERIFICATION: SequenceHandle.cancel() was called.")
		is_running = false
