# src/core/event_bus.gd
extends Node

var _subscribers: Dictionary = {}
var _by_id: Dictionary = {}
var _next_id: int = 1
var _event_queue: Array = []
var _trace_capacity: int = 200
var _trace: Array = []

var debug_enabled: bool = OS.is_debug_build()

func _process(_delta: float) -> void:
	if _event_queue.is_empty(): return
	var q = _event_queue.duplicate()
	_event_queue.clear()
	for item in q:
		_emit_internal(item["event"], item["payload"], item["source"])

func on(event_name: String, callback: Callable, opts: Dictionary = {}) -> int:
	assert(callback.is_valid(), "EventBus.on: callback must be a valid Callable")
	var subs: Array = _subscribers.get(event_name, [])
	var owner_node = callback.get_object()
	var weak_ref = weakref(owner_node) if owner_node is Node else null

	var entry := {
		"id": _next_id, "callback": callback, "owner_weak": weak_ref,
		"once": opts.get("once", false), "priority": opts.get("priority", 0),
		"type": opts.get("type", null)
	}
	subs.append(entry)
	subs.sort_custom(func(a, b): return a.priority > b.priority)
	_subscribers[event_name] = subs
	_by_id[_next_id] = event_name
	_next_id += 1
	return entry.id

func off(token: int) -> void:
	if not _by_id.has(token): return
	var event_name: String = _by_id[token]
	if _subscribers.has(event_name):
		for i in range(_subscribers[event_name].size() - 1, -1, -1):
			if _subscribers[event_name][i].id == token:
				_subscribers[event_name].remove_at(i)
				break
		if _subscribers[event_name].is_empty():
			_subscribers.erase(event_name)
	_by_id.erase(token)

func off_owner(owner_node: Node) -> void:
	if owner_node == null: return
	var tokens_to_remove: Array[int] = []
	for token in _by_id.keys():
		var event_name = _by_id[token]
		if _subscribers.has(event_name):
			var subs = _subscribers[event_name]
			for sub in subs:
				if sub.id == token and sub.owner_weak and sub.owner_weak.get_ref() == owner_node:
					tokens_to_remove.append(token)
	for token in tokens_to_remove:
		off(token)

func emit(event_name: String, payload = null, source: Object = null) -> void:
	_emit_internal(event_name, payload, source)

func emit_async(event_name: String, payload = null, source: Object = null) -> void:
	_event_queue.append({"event": event_name, "payload": payload, "source": source})

func _emit_internal(event_name: String, payload, source: Object) -> void:
	if debug_enabled:
		var payload_class = "null"
		if payload != null: payload_class = payload.get_class()
		var source_str = "invalid"
		if is_instance_valid(source): source_str = str(source)
		
		_trace.append({ "time": Time.get_ticks_msec(), "event": event_name,
			"payload_type": payload_class, "source": source_str })
		if _trace.size() > _trace_capacity: _trace.pop_front()

	if not _subscribers.has(event_name): return

	for sub in _subscribers[event_name].duplicate():
		if sub.owner_weak and not sub.owner_weak.get_ref():
			off(sub.id); continue
		
		var expected_type = sub.type
		if expected_type and not is_instance_of(payload, expected_type):
			if debug_enabled:
				var type_path = expected_type.resource_path if expected_type is Script else str(expected_type)
				
				# IMPROVED DEBUG MESSAGE: Get the specific script name if available.
				var payload_type_name = "null"
				if payload:
					if payload is Resource and payload.get_script():
						payload_type_name = payload.get_script().resource_path
					else:
						payload_type_name = payload.get_class()

				print("EventBus: Subscriber for '%s' expected type %s but got %s. Skipping." % [event_name, type_path, payload_type_name])
			continue
		
		sub.callback.call(payload)
		
		if sub.once: off(sub.id)

# --- Debugging Tools ---
func debug_recent_events() -> Array: return _trace.duplicate()

func dump_subscribers(event_name: String = "") -> Dictionary:
	var output := {}
	var events_to_dump: Array = _subscribers.keys() if event_name.is_empty() else [event_name]

	for ev in events_to_dump:
		if _subscribers.has(ev):
			output[ev] = []
			for sub in _subscribers[ev]:
				var owner_desc := "null"
				if sub.owner_weak and sub.owner_weak.get_ref():
					owner_desc = str(sub.owner_weak.get_ref())
				
				var type_desc := "any"
				if sub.type and sub.type is Script:
					type_desc = sub.type.resource_path
				
				output[ev].append({ "id": sub.id, "owner": owner_desc, "priority": sub.priority,
					"once": sub.once, "type": type_desc })
	return output
