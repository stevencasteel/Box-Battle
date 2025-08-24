# src/tests/fakes/fake_event_bus.gd
## A test-double (fake) implementation of the EventBus for use in unit tests.
##
## This fake mimics the public API of the real EventBus but does not dispatch
## events globally. Instead, it records all emitted events, allowing tests
## to assert that specific events were fired with specific payloads.
class_name FakeEventBus
extends Node

var _emitted_events: Array[Dictionary] = []


## Records an emitted event for later inspection.
func emit(event_name: StringName, payload = null) -> void:
	_emitted_events.append({"name": event_name, "payload": payload})


## A no-op implementation for the 'on' method.
func on(_event_name: StringName, _callback: Callable) -> int:
	return 1  # Return a dummy token


## A no-op implementation for the 'off' method.
func off(_token: int) -> void:
	pass


## Clears all recorded events. Should be called in a test's `before_each`.
func clear() -> void:
	_emitted_events.clear()


## Checks if a specific event was emitted.
func was_event_emitted(event_name: StringName) -> bool:
	for event in _emitted_events:
		if event.name == event_name:
			return true
	return false


## Returns the payload of the first event found with the given name.
func get_payload_for_event(event_name: StringName) -> Variant:
	for event in _emitted_events:
		if event.name == event_name:
			return event.payload
	return null
