# src/tests/fakes/fake_event_bus.gd
## A test-double (fake) that inherits from EventBus to satisfy type checks,
## but provides custom recording logic for use in unit tests.
class_name FakeEventBus
extends "res://src/core/events/event_bus.gd"

var _emitted_events: Array[Dictionary] = []

func _ready() -> void:
	# Override parent's _ready to be a no-op in a test environment.
	pass

## Records an emitted event for later inspection instead of dispatching it.
func emit(event_name: StringName, payload = null) -> void:
	_emitted_events.append({"name": event_name, "payload": payload})

## Clears all recorded events.
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