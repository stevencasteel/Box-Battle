# src/core/events/event_bus.gd
## An autoloaded singleton that provides a global event dispatch system.
##
## This allows for loosely-coupled communication between disparate parts of the
## codebase, such as between gameplay systems and the UI.
extends Node

# --- Private Member Variables ---
var _subscribers: Dictionary = {}
var _by_id: Dictionary = {}
var _next_id: int = 1

# --- Godot Lifecycle Methods ---


func _exit_tree() -> void:
	# Clear all subscriptions to break potential cyclic references on exit.
	_subscribers.clear()
	_by_id.clear()


# --- Public Methods ---


## Subscribes a callback to a specific event. Returns a token ID for unsubscribing.
func on(event_name: StringName, callback: Callable) -> int:
	assert(callback.is_valid(), "EventBus.on: callback must be a valid Callable")

	var subs: Array = _subscribers.get(event_name, [])
	var owner_node = callback.get_object()
	var weak_ref = weakref(owner_node) if owner_node is Node else null

	var entry := {
		"id": _next_id,
		"callback": callback,
		"owner_weak": weak_ref,
	}
	subs.append(entry)
	_subscribers[event_name] = subs

	_by_id[_next_id] = event_name  # Map the token ID back to the event name
	_next_id += 1
	return entry.id


## Unsubscribes from an event using the token returned by on().
func off(token: int) -> void:
	if not _by_id.has(token):
		return

	var event_name: StringName = _by_id[token]
	if _subscribers.has(event_name):
		var subs = _subscribers[event_name]
		for i in range(subs.size() - 1, -1, -1):
			if subs[i].id == token:
				subs.remove_at(i)
				break
		if subs.is_empty():
			_subscribers.erase(event_name)

	_by_id.erase(token)


## Emits an event to all subscribers.
func emit(event_name: StringName, payload = null) -> void:
	if not _subscribers.has(event_name):
		return

	var subs: Array = _subscribers[event_name]
	# Iterate backwards to safely remove dead references during the loop.
	for i in range(subs.size() - 1, -1, -1):
		var sub = subs[i]

		# Auto-prune subscriptions whose owner nodes have been freed.
		if sub.owner_weak and not sub.owner_weak.get_ref():
			_by_id.erase(sub.id)
			subs.remove_at(i)
			continue

		sub.callback.call(payload)

	if subs.is_empty():
		_subscribers.erase(event_name)
