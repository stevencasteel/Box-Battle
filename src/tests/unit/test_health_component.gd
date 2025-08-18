# src/tests/unit/test_health_component.gd
extends GutTest

# --- Constants ---
const HealthComponent = preload("res://src/entities/components/health_component.gd")
const Player = preload("res://src/entities/player/player.tscn")
const DamageInfo = preload("res://src/api/combat/damage_info.gd")
const CombatConfig = preload("res://data/combat_config.tres")
const Identifiers = preload("res://src/core/util/identifiers.gd")

# --- Test Internals ---
var _player: Player
var _health_component: HealthComponent
var _damage_source: Node2D
var _died_signal_was_emitted: bool = false

# --- Test Lifecycle ---

func before_each():
	_died_signal_was_emitted = false
	# We use a partial_double to prevent the Player's own _ready function from running.
	_player = partial_double(Player).instantiate()
	_player.name = "TestPlayer"
	_player.add_to_group(Identifiers.Groups.PLAYER)
	add_child(_player)

	# We must manually ready the component since the Player's _ready is stubbed.
	_health_component = _player.get_node("HealthComponent")
	_health_component._ready()

	# Manually call setup with our test dependencies.
	var dependencies = {
		"data_resource": _player.p_data,
		"config": CombatConfig
	}
	_health_component.setup(_player, dependencies)

	_damage_source = Node2D.new()
	add_child(_damage_source)

func after_each():
	if is_instance_valid(_health_component) and _health_component.died.is_connected(_on_health_component_died):
		_health_component.died.disconnect(_on_health_component_died)

	# THE FIX: Use free() instead of queue_free() for immediate cleanup in a test context.
	if is_instance_valid(_player):
		_player.free()
	if is_instance_valid(_damage_source):
		_damage_source.free()

# --- The Tests ---

func test_initial_health_is_max_health():
	assert_eq(_player.p_data.health, _player.p_data.max_health, "Health should be max at start.")

func test_apply_damage_reduces_health():
	var initial_health = _player.p_data.health
	var damage_info = DamageInfo.new()
	damage_info.amount = 2
	damage_info.source_node = _damage_source

	var result = _health_component.apply_damage(damage_info)
	
	assert_true(result.was_damaged, "The apply_damage result should indicate damage was taken.")
	assert_eq(_player.p_data.health, initial_health - 2, "Health should be reduced by 2.")

func test_cannot_damage_when_invincible():
	var damage_info = DamageInfo.new()
	damage_info.amount = 1
	damage_info.source_node = _damage_source
	_health_component.apply_damage(damage_info)
	
	assert_true(_player.p_data.is_invincible, "Player should be invincible after first hit.")
	
	var result = _health_component.apply_damage(damage_info)
	assert_false(result.was_damaged, "Should not be able to take damage while invincible.")
	assert_eq(_player.p_data.health, _player.p_data.max_health - 1, "Health should not have changed on second hit.")

func test_died_signal_emitted_when_health_is_zero():
	var damage_info = DamageInfo.new()
	damage_info.amount = _player.p_data.max_health
	damage_info.source_node = _damage_source

	_health_component.died.connect(_on_health_component_died)
	_health_component.apply_damage(damage_info)
	await get_tree().physics_frame

	assert_true(_died_signal_was_emitted, "The 'died' signal should have been emitted.")
	assert_eq(_player.p_data.health, 0, "Health should be 0 after lethal damage.")

# --- Signal Handlers ---

func _on_health_component_died():
	_died_signal_was_emitted = true