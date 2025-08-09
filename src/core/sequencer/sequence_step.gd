# src/core/sequencer/sequence_step.gd
# The abstract base class for all steps in a sequence.
# It defines the contract that all steps must follow: an `execute` method.
@tool
class_name SequenceStep
extends Resource

# This method will be implemented by all concrete step classes.
# It contains the logic for what the step actually does.
# It should return a Signal or Coroutine object if the sequence needs to pause.
#
# CORRECTED: The parameter is prefixed with an underscore to resolve the
# UNUSED_PARAMETER warning in this base class.
func execute(_sequencer_node: Node) -> Variant:
	return null
