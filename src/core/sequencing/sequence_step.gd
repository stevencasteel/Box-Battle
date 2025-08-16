# src/core/sequencing/sequence_step.gd
@tool
## The abstract base class for all steps in a sequence.
##
## It defines the contract that all steps must follow: an `execute` method.
class_name SequenceStep
extends Resource

# --- Virtual Methods ---

## This method is implemented by all concrete step classes. It contains the
## logic for what the step does. It can return a [Signal] or [Coroutine]
## to make the [Sequencer] pause execution.
func execute(_sequencer_node: Node) -> Variant:
	return null