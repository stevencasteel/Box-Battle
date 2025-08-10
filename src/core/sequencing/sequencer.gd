# src/core/sequencer.gd
#
# An autoloaded singleton that runs sequences of timed events. This version has
# been refactored to use type-safe `SequenceStep` resources and now uses a more
# robust await pattern that satisfies the static analyzer.
extends Node

# The primary function of the sequencer. It iterates through an array of
# SequenceStep objects, executing each one in order.
func run_sequence(steps: Array[SequenceStep]) -> void:
	if steps.is_empty():
		return

	for step in steps:
		if not step is SequenceStep:
			push_warning("Sequencer: Invalid step found (not a SequenceStep resource). Skipping.")
			continue
		
		# CORRECTED: The step's execute method now returns an awaitable object
		# (like a Signal) if it needs to pause the sequence. We check for this
		# and only await if necessary. This resolves the REDUNDANT_AWAIT warning.
		var awaitable = step.execute(self)
		if awaitable:
			await awaitable
