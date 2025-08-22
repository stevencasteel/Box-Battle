# src/tests/unit/test_health_component.gd
extends GutTest

# --- Constants ---
const HealthComponent = preload("res://src/entities/components/health_component.gd")
const PlayerStateData = preload("res://src/entities/player/data/player_state_data.gd")
const DamageInfo = preload("res://src/api/combat/damage_info.gd")
const CombatConfig = preload("res://src/data/combat_config.tres")
const Identifiers = preload("res://src/core/util/identifiers.gd")
const FakeFXManager = preload("res://src/tests/fakes/fake_fx_manager.gd")

# --- Test Internals ---
var _health_component: HealthComponent
var _player_data: PlayerStateData
var _damage_source: Node2D
var _died_signal_was_emitted: bool = false
var _mock_owner: CharacterBody2D

# --- Test Lifecycle ---

func before_each():
	_died_signal_was_emitted = false

	_mock_owner = CharacterBody2D.new()
	_mock_owner.name = "TestPlayer"
	_mock_owner.add_to_group(Identifiers.Groups.PLAYER)
	add_child(_mock_owner)

	_player_data = PlayerStateData.new()
	_player_data.config = CombatConfig
	_player_data.max_health = 10 # Use a known value for tests
	_player_data.health = 10
	
	_health_component = HealthComponent.new()
	_mock_owner.add_child(_health_component)

	var dependencies = {
		"data_resource": _player_data,
		"config": CombatConfig,
		"fx_manager": FakeFXManager.new() # Inject the fake
	}
	_health_component.setup(_mock_owner, dependencies)

	_damage_source = Node2D.new()
	add_child(_damage_source)

func after_each():
	if is_instance_valid(_health_component) and _health_component.died.is_connected(_on_health_component_died):
		_health_component.died.disconnect(_on_health_component_died)

# --- The Tests ---

func test_initial_health_is_max_health():
	assert_eq(_player_data.health, _player_data.max_health, "Health should be max at start.")

func test_apply_damage_reduces_health():
	var initial_health = _player_data.health
	var damage_info = DamageInfo.new()
	damage_info.amount = 2
	damage_info.source_node = _damage_source

	var result = _health_component.apply_damage(damage_info)
	
	assert_true(result.was_damaged, "The apply_damage result should indicate damage was taken.")
	assert_eq(_player_data.health, initial_health - 2, "Health should be reduced by 2.")

func test_cannot_damage_when_invincible():
	var damage_info = DamageInfo.new()
	damage_info.amount = 1
	damage_info.source_node = _damage_source
	_health_component.apply_damage(damage_info)
	
	assert_true(_health_component.is_invincible(), "Player should be invincible after first hit.")
	
	var result = _health_component.apply_damage(damage_info)
	assert_false(result.was_damaged, "Should not be able to take damage while invincible.")
	assert_eq(_player_data.health, _player_data.max_health - 1, "Health should not have changed on second hit.")

func test_died_signal_emitted_when_health_is_zero():
	var damage_info = DamageInfo.new()
	damage_info.amount = _player_data.max_health
	damage_info.source_node = _damage_source

	_health_component.died.connect(_on_health_component_died)
	_health_component.apply_damage(damage_info)
	await get_tree().process_frame

	assert_true(_died_signal_was_emitted, "The 'died' signal should have been emitted.")
	assert_eq(_player_data.health, 0, "Health should be 0 after lethal damage.")

# --- Signal Handlers ---

func _on_health_component_died():
	_died_signal_was_emitted = true