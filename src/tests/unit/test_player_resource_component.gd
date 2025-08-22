# src/tests/unit/test_player_resource_component.gd
extends GutTest

# --- Constants ---
const PlayerResourceComponent = preload("res://src/entities/player/components/player_resource_component.gd")
const PlayerStateData = preload("res://src/entities/player/data/player_state_data.gd")
const CombatConfig = preload("res://src/data/combat_config.tres")
const EventCatalog = preload("res://src/core/events/event_catalog.gd")
const FakeEventBus = preload("res://src/tests/fakes/fake_event_bus.gd")

# --- Test Internals ---
var _resource_component: PlayerResourceComponent
var _player_data: PlayerStateData
var _fake_event_bus: FakeEventBus

# --- Test Lifecycle ---

func before_each():
	# Create a fake owner and the data resource.
	var mock_owner = Node.new()
	add_child(mock_owner)
	_player_data = PlayerStateData.new()
	_player_data.config = CombatConfig

	# Instantiate the fake and the component under test.
	_fake_event_bus = FakeEventBus.new()
	add_child(_fake_event_bus)
	_resource_component = PlayerResourceComponent.new()
	mock_owner.add_child(_resource_component)

	# Inject the fakes and dependencies.
	var dependencies = {
		"data_resource": _player_data,
		"event_bus": _fake_event_bus
	}
	_resource_component.setup(mock_owner, dependencies)

func after_each():
	# The test runner will free the mock_owner, which frees its children.
	pass

# --- The Tests ---

func test_on_damage_dealt_increments_determination():
	var initial_determination = _player_data.determination_counter
	_resource_component.on_damage_dealt()
	assert_eq(_player_data.determination_counter, initial_determination + 1, "Determination should increment by 1.")

func test_healing_charge_gained_at_threshold():
	_player_data.healing_charges = 0
	_player_data.determination_counter = CombatConfig.player_determination_per_charge - 1

	_resource_component.on_damage_dealt()

	assert_eq(_player_data.healing_charges, 1, "Should gain 1 healing charge at the threshold.")
	assert_eq(_player_data.determination_counter, 0, "Determination should reset to 0 after gaining a charge.")

func test_healing_charges_are_capped():
	_player_data.healing_charges = CombatConfig.player_max_healing_charges
	_player_data.determination_counter = CombatConfig.player_determination_per_charge - 1

	_resource_component.on_damage_dealt()

	assert_eq(_player_data.healing_charges, CombatConfig.player_max_healing_charges, "Healing charges should not exceed the max.")
	assert_eq(_player_data.determination_counter, CombatConfig.player_determination_per_charge - 1, "Determination should not increment if charges are already at max.")

func test_event_emitted_when_charge_gained():
	_player_data.healing_charges = 0
	_player_data.determination_counter = CombatConfig.player_determination_per_charge - 1

	_resource_component.on_damage_dealt()
	
	assert_true(_fake_event_bus.was_event_emitted(EventCatalog.PLAYER_HEALING_CHARGES_CHANGED), "Should emit PLAYER_HEALING_CHARGES_CHANGED event.")
	
	var payload: PlayerHealingChargesChangedEvent = _fake_event_bus.get_payload_for_event(EventCatalog.PLAYER_HEALING_CHARGES_CHANGED)
	assert_not_null(payload, "Event payload should not be null.")
	assert_eq(payload.current_charges, 1, "Event payload should contain the correct new charge count.")