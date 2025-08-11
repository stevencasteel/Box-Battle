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
	
	# The key is the token ID, the value is the event name.
	_by_id[_next_id] = event_name
	
	_next_id += 1
	return entry.id

func off(token: int) -> void:
	if not _by_id.has(token): return
	
	# CORRECTED: Get the event name from the dictionary.
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

# CORRECTED: Added underscore to unused parameter `_source`.
func emit(event_name: StringName, payload = null, _source: Object = null) -> void:
	if not _subscribers.has(event_name): return

	var subs: Array = _subscribers[event_name]
	
	for i in range(subs.size() - 1, -1, -1):
		var sub = subs[i]
		
		if sub.owner_weak and not sub.owner_weak.get_ref():
			_by_id.erase(sub.id)
			subs.remove_at(i)
			continue
		
		sub.callback.call(payload)
	
	if subs.is_empty():
		_subscribers.erase(event_name)
