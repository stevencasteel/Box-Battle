# src/tests/fakes/fake_service_locator.gd
## A test-double for the ServiceLocator singleton.
## It inherits from the real ServiceLocator to satisfy type checks but overrides
## _ready() to prevent it from looking for other singletons and to allow
## injecting fakes over the real @onready properties.
class_name FakeServiceLocator
extends "res://src/core/util/service_locator.gd"

# --- Fake Service Properties ---
var mock_event_bus: Node
var mock_fx_manager: Node
var mock_object_pool: Node
var mock_combat_utils: Node


func _ready() -> void:
	# This _ready function is crucial. It overrides the parent's _ready,
	# preventing it from failing.
	
	# After the parent's @onready vars have been populated with real singletons,
	# we now overwrite them with our mocks for the test.
	if is_instance_valid(mock_event_bus):
		self.event_bus = mock_event_bus
	if is_instance_valid(mock_fx_manager):
		self.fx_manager = mock_fx_manager
	if is_instance_valid(mock_object_pool):
		self.object_pool = mock_object_pool
	if is_instance_valid(mock_combat_utils):
		self.combat_utils = mock_combat_utils