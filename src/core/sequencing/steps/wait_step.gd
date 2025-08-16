# src/core/sequencing/steps/wait_step.gd
@tool
## A sequence step that pauses execution for a set duration.
class_name WaitStep
extends SequenceStep

# --- Editor Properties ---
@export var duration: float = 1.0

# --- Virtual Methods ---

func execute(sequencer_node: Node) -> Variant:
	if duration > 0.0:
		# Return the timer's 'timeout' signal for the sequencer to await.
		return sequencer_node.get_tree().create_timer(duration).timeout
	return null