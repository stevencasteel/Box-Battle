# src/core/sequencer/steps/wait_step.gd
# A sequence step that pauses execution for a set duration.
@tool
class_name WaitStep
extends SequenceStep

@export var duration: float = 1.0

# CORRECTED: This function now returns the timer's 'timeout' signal.
# The sequencer will await this signal, making the pause explicit.
func execute(sequencer_node: Node) -> Variant:
	if duration > 0.0:
		return sequencer_node.get_tree().create_timer(duration).timeout
	return null