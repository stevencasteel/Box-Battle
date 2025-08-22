# src/tests/unit/test_player_resource_component.gd
extends GutTest

# --- Constants ---
const Player = preload("res://src/entities/player/player.tscn")
const PlayerResourceComponent = preload("res://src/entities/player/components/player_resource_component.gd")
const CombatConfig = preload("res://src/data/combat_config.tres")
const EventCatalog = preload("res://src/core/events/event_catalog.gd")

# --- Test Internals ---
var _player: Player
var _resource_component: PlayerResourceComponent
var _healing_charge_event_fired: bool = false
var _event_token: int

# --- Test Lifecycle ---

func before_each():
	_healing_charge_event_fired = false
	_player = partial_double(Player).instantiate()
	if _player.has_method("inject_dependencies"):
		_player.inject_dependencies({
			"object_pool": get_node("/root/ObjectPool"),
			"fx_manager": get_node("/root/FXManager"),
			"event_bus": get_node("/root/EventBus")
		})
	add_child(_player)

	_resource_component = _player.get_node("PlayerResourceComponent")
	var dependencies = {
		"data_resource": _player.entity_data,
		"event_bus": get_node("/root/EventBus")
	}
	_resource_component.setup(_player, dependencies)

	_event_token = EventBus.on(EventCatalog.PLAYER_HEALING_CHARGES_CHANGED, Callable(self, "_on_healing_charges_changed"))

func after_each():
	EventBus.off(_event_token)
	_player.queue_free()

# --- The Tests ---

func test_on_damage_dealt_increments_determination():
	var initial_determination = _player.entity_data.determination_counter
	_resource_component.on_damage_dealt()
	assert_eq(_player.entity_data.determination_counter, initial_determination + 1, "Determination should increment by 1.")

func test_healing_charge_gained_at_threshold():
	_player.entity_data.healing_charges = 0
	_player.entity_data.determination_counter = CombatConfig.player_determination_per_charge - 1

	_resource_component.on_damage_dealt()

	assert_eq(_player.entity_data.healing_charges, 1, "Should gain 1 healing charge at the threshold.")
	assert_eq(_player.entity_data.determination_counter, 0, "Determination should reset to 0 after gaining a charge.")

func test_healing_charges_are_capped():
	_player.entity_data.healing_charges = CombatConfig.player_max_healing_charges
	_player.entity_data.determination_counter = CombatConfig.player_determination_per_charge - 1

	_resource_component.on_damage_dealt()

	assert_eq(_player.entity_data.healing_charges, CombatConfig.player_max_healing_charges, "Healing charges should not exceed the max.")
	assert_eq(_player.entity_data.determination_counter, CombatConfig.player_determination_per_charge - 1, "Determination should not increment if charges are already at max.")

func test_event_emitted_when_charge_gained():
	_player.entity_data.healing_charges = 0
	_player.entity_data.determination_counter = CombatConfig.player_determination_per_charge - 1

	_resource_component.on_damage_dealt()
	
	await get_tree().process_frame

	assert_true(_healing_charge_event_fired, "Should emit PLAYER_HEALING_CHARGES_CHANGED event.")

# --- Signal Handlers ---

func _on_healing_charges_changed(_payload):
	_healing_charge_event_fired = true