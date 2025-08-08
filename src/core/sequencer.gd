# src/core/sequencer.gd
#
# An autoloaded singleton that runs sequences of timed events. This provides a
# clean, data-driven way to script boss intros, multi-stage attacks, and any
# other "cutscene-like" behavior without cluttering game logic with timers.
#
# It is designed to be called with 'await' for easy integration into async flows.
# Example: await Sequencer.run_sequence(my_steps_array)
#
extends Node
# CLASS NAME REMOVED TO PREVENT CONFLICT WITH AUTOLOAD NAME

# --- EXAMPLE STEP FORMATS ---
# { "type": "wait", "duration": 2.0 }
# { "type": "emit", "event": EventCatalog.BOSS_SPAWNED, "payload": { ... } }
# { "type": "call", "node": some_node, "function": "do_super_attack", "args": [arg1, arg2] }
# { "type": "await_signal", "node": some_node, "signal_name": "animation_finished" }
#

# --- PUBLIC API ---

# The primary function of the sequencer. It iterates through an array of
# dictionaries, executing each step in order.
func run_sequence(steps: Array) -> void:
	if steps.is_empty():
		return

	for step in steps:
		# Ensure the step is a valid dictionary before processing.
		if not step is Dictionary:
			push_warning("Sequencer: Invalid step found (not a Dictionary). Skipping.")
			continue

		var type = step.get("type", "")
		match type:
			"wait":
				await _execute_wait(step)
			"emit":
				_execute_emit(step)
			"call":
				_execute_call(step)
			"await_signal":
				await _execute_await_signal(step)
			_:
				push_warning("Sequencer: Unknown step type encountered: '%s'" % type)

# --- INTERNAL STEP HANDLERS ---

func _execute_wait(step: Dictionary) -> void:
	var duration = float(step.get("duration", 0.0))
	if duration > 0.0:
		await get_tree().create_timer(duration).timeout

func _execute_emit(step: Dictionary) -> void:
	var event_name = step.get("event", "")
	if event_name.is_empty():
		push_warning("Sequencer: 'emit' step is missing 'event' name.")
		return
	var payload = step.get("payload", null)
	# Use the existing EventBus to broadcast the event system-wide.
	EventBus.emit(event_name, payload)

func _execute_call(step: Dictionary) -> void:
	var node = step.get("node", null)
	var function_name = step.get("function", "")
	var args = step.get("args", [])

	if not is_instance_valid(node):
		push_warning("Sequencer: 'call' step has an invalid or null node.")
		return
	if function_name.is_empty() or not node.has_method(function_name):
		push_warning("Sequencer: 'call' step has an invalid function name: '%s' on node %s" % [function_name, node.name])
		return

	# Call the function on the target node with the provided arguments.
	node.callv(function_name, args)

func _execute_await_signal(step: Dictionary) -> void:
	var node = step.get("node", null)
	var signal_name = step.get("signal_name", "")

	if not is_instance_valid(node):
		push_warning("Sequencer: 'await_signal' step has an invalid or null node.")
		return
	if signal_name.is_empty():
		push_warning("Sequencer: 'await_signal' step is missing 'signal_name'.")
		return

	# This powerful one-liner pauses the sequence until the specified node
	# emits the specified signal.
	await node[signal_name]