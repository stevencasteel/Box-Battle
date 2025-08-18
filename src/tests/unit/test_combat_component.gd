# src/tests/unit/test_combat_component.gd
extends GutTest

# --- Constants ---
const Player = preload("res://src/entities/player/player.tscn")
const CombatComponent = preload("res://src/entities/components/combat_component.gd")
const HealthComponent = preload("res://src/entities/components/health_component.gd")
const DamageResult = preload("res://src/api/combat/damage_result.gd")
const CombatConfig = preload("res://data/combat_config.tres")
const Identifiers = preload("res://src/core/util/identifiers.gd")

# --- Test Internals ---
var _player: Player
var _combat_component: CombatComponent
var _object_pool: ObjectPool
var _pogo_bounce_was_requested: bool = false

# --- Test Lifecycle ---

func before_each():
	_pogo_bounce_was_requested = false

	# Get a reference to the real ObjectPool to monitor its state
	_object_pool = get_node("/root/ObjectPool")
	_object_pool.reset()

	# Create a partial double of the Player. This gives us a real Player node
	# with all its components, but we can stub out its functions if needed.
	_player = partial_double(Player).instantiate()
	add_child(_player)

	_combat_component = _player.get_node("CombatComponent")
	var dependencies = { "data_resource": _player.p_data }
	_combat_component.setup(_player, dependencies)

	# Connect the component's signal to our local test handler
	_combat_component.pogo_bounce_requested.connect(_on_pogo_bounce_requested)
	
	await get_tree().process_frame

func after_each():
	if is_instance_valid(_combat_component) and _combat_component.pogo_bounce_requested.is_connected(_on_pogo_bounce_requested):
		_combat_component.pogo_bounce_requested.disconnect(_on_pogo_bounce_requested)

	if is_instance_valid(_player):
		_player.free()

# --- The Tests ---

func test_fire_shot_gets_instance_from_pool():
	var stats_before = _object_pool.get_pool_stats()
	var initial_active_count = stats_before[Identifiers.Pools.PLAYER_SHOTS].active

	_combat_component.fire_shot()
	await get_tree().process_frame # Allow shot to be added to scene

	var stats_after = _object_pool.get_pool_stats()
	var final_active_count = stats_after[Identifiers.Pools.PLAYER_SHOTS].active

	assert_eq(final_active_count, initial_active_count + 1, "fire_shot() should make one more projectile active in the pool.")

func test_trigger_pogo_on_enemy_emits_bounce_request():
	var mock_enemy = CharacterBody2D.new()
	var mock_health = double(HealthComponent).new()
	mock_health.name = "HealthComponent"
	stub(mock_health, "apply_damage").to_return(DamageResult.new())
	mock_enemy.add_child(mock_health)
	add_child(mock_enemy)

	var pogo_succeeded = _combat_component.trigger_pogo(mock_enemy)
	await get_tree().process_frame

	assert_true(pogo_succeeded, "trigger_pogo should return true when hitting a valid enemy.")
	assert_true(_pogo_bounce_was_requested, "pogo_bounce_requested signal should be emitted after a successful pogo.")

	# THE FIX: Explicitly free the test double and its parent.
	mock_health.free()
	mock_enemy.free()

func test_trigger_pogo_on_projectile_returns_it_to_pool():
	# This test requires a real pooled projectile instance.
	var mock_projectile = _object_pool.get_instance(Identifiers.Pools.TURRET_SHOTS)
	# Set the required metadata for pogo to work on it
	mock_projectile.add_to_group(Identifiers.Groups.ENEMY_PROJECTILE)
	_player.p_data.is_pogo_attack = true # The component checks this flag

	var stats_before = _object_pool.get_pool_stats()
	var initial_active_count = stats_before[Identifiers.Pools.TURRET_SHOTS].active
	assert_eq(initial_active_count, 1, "There should be 1 active turret shot before the test.")

	_combat_component.trigger_pogo(mock_projectile)
	await get_tree().process_frame # Allow the deferred return_instance to process

	var stats_after = _object_pool.get_pool_stats()
	var final_active_count = stats_after[Identifiers.Pools.TURRET_SHOTS].active
	
	assert_eq(final_active_count, 0, "Pogoing a projectile should return it to the pool, making 0 active.")

# --- Signal Handlers ---

func _on_pogo_bounce_requested():
	_pogo_bounce_was_requested = true