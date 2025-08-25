# src/tests/unit/test_player_resource_component.gd
extends GutTest

# --- Constants ---
const PlayerResourceComponent = preload("res://src/entities/player/components/player_resource_component.gd")
const PlayerStateData = preload("res://src/entities/player/data/player_state_data.gd")
const CombatConfig = preload("res://src/data/combat_config.tres")
const EventCatalog = preload("res://src/core/events/event_catalog.gd")

# --- Test Internals ---
var _resource_component: PlayerResourceComponent
var _player_data: PlayerStateData
var _fake_event_bus # Will be created at runtime

# --- Test Lifecycle ---
func before_each():
	# 1. Instantiate fakes
	var FakeEventBusScript = load("res://src/tests/fakes/fake_event_bus.gd")
	_fake_event_bus = FakeEventBusScript.new()
	add_child_autofree(_fake_event_bus)

	var FakeServiceLocatorScript = load("res://src/tests/fakes/fake_service_locator.gd")
	var fake_services = FakeServiceLocatorScript.new()

	fake_services.mock_event_bus = _fake_event_bus
	add_child_autofree(fake_services)

	# 2. Setup test subject and its data
	var mock_owner = Node.new()
	add_child_autofree(mock_owner)
	_player_data = PlayerStateData.new()
	_player_data.config = CombatConfig
	# Explicitly set max charges for clarity in tests
	_player_data.max_healing_charges = 3

	_resource_component = PlayerResourceComponent.new()
	mock_owner.add_child(_resource_component)

	# 3. Inject dependencies
	var dependencies = {"data_resource": _player_data, "services": fake_services}
	_resource_component.setup(mock_owner, dependencies)

# --- The Tests ---
func test_on_damage_dealt_increments_determination():
	_player_data.determination_counter = 0
	_resource_component.on_damage_dealt()
	assert_eq(_player_data.determination_counter, 1, "Determination should increment by 1.")
	assert_false(_fake_event_bus.was_event_emitted(EventCatalog.PLAYER_HEALING_CHARGES_CHANGED))

func test_healing_charge_gained_at_threshold():
	_player_data.healing_charges = 0
	_player_data.determination_counter = CombatConfig.player_determination_per_charge - 1

	_resource_component.on_damage_dealt()

	assert_eq(_player_data.healing_charges, 1, "Should gain 1 healing charge at the threshold.")
	assert_eq(_player_data.determination_counter, 0, "Determination should reset to 0.")
	assert_true(_fake_event_bus.was_event_emitted(EventCatalog.PLAYER_HEALING_CHARGES_CHANGED))
	var payload = _fake_event_bus.get_payload_for_event(EventCatalog.PLAYER_HEALING_CHARGES_CHANGED)
	assert_eq(payload.current_charges, 1, "Event payload should contain the new charge count.")

func test_healing_charges_are_capped():
	_player_data.healing_charges = _player_data.max_healing_charges
	_player_data.determination_counter = CombatConfig.player_determination_per_charge - 1
	_resource_component.on_damage_dealt()

	assert_eq(_player_data.healing_charges, _player_data.max_healing_charges, "Charges should not exceed max.")
	assert_eq(
		_player_data.determination_counter,
		CombatConfig.player_determination_per_charge - 1,
		"Determination should not increment if charges are max."
	)
	assert_false(_fake_event_bus.was_event_emitted(EventCatalog.PLAYER_HEALING_CHARGES_CHANGED))

func test_consume_charge_decrements_and_emits_event():
	# Start with a valid number of charges (at max) and consume one.
	_player_data.healing_charges = _player_data.max_healing_charges # Starts at 3
	_resource_component.consume_healing_charge()
	assert_eq(_player_data.healing_charges, 2, "Healing charges should decrement by 1.")
	assert_true(_fake_event_bus.was_event_emitted(EventCatalog.PLAYER_HEALING_CHARGES_CHANGED))
	var payload = _fake_event_bus.get_payload_for_event(EventCatalog.PLAYER_HEALING_CHARGES_CHANGED)
	assert_eq(payload.current_charges, 2, "Event payload should contain the correct new charge count.")

func test_consume_charge_does_nothing_at_zero():
	_player_data.healing_charges = 0
	_resource_component.consume_healing_charge()
	assert_eq(_player_data.healing_charges, 0, "Healing charges should remain 0.")
	assert_false(_fake_event_bus.was_event_emitted(EventCatalog.PLAYER_HEALING_CHARGES_CHANGED))