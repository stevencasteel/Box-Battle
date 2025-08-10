# src/core/event_bus.gd
# SIMPLIFIED: Removed async queue, priority sorting, and unused debug features.
extends Node

var _subscribers: Dictionary = {}
var _by_id: Dictionary = {}
var _next_id: int = 1

func on(event_name: StringName, callback: Callable) -> int:
	assert(callback.is_valid(), "EventBus.on: callback must be a valid Callable")
	var subs: Array = _subscribers.get(event_name, [])
	var owner_node = callback.get_object()
	var weak_ref = weakref(owner_node) if owner_node is Node else null

	var entry := {
		"id": _next_id, "callback": callback, "owner_weak": weak_ref,
	}
	subs.append(entry)
	_subscribers[event_name] = subs
	_by_id[_next_id] = event_name
	_next_id += 1
	return entry.id

func off(token: int) -> void:
	if not _by_id.has(token): return
	var event_name: StringName = _by_id[token]
	if _subscribers.has(event_name):
		for i in range(_subscribers[event_name].size() - 1, -1, -1):
			if _subscribers[event_name][i].id == token:
				_subscribers[event_name].remove_at(i)
				break
		if _subscribers[event_name].is_empty():
			_subscribers.erase(event_name)
	_by_id.erase(token)

# CORRECTED: Added underscore to unused parameter `_source`.
func emit(event_name: StringName, payload = null, _source: Object = null) -> void:
	if not _subscribers.has(event_name): return

	for sub in _subscribers[event_name].duplicate():
		if sub.owner_weak and not sub.owner_weak.get_ref():
			off(sub.id)
			continue
		
		sub.callback.call(payload)
