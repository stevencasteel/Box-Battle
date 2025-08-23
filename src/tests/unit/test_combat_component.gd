# src/tests/unit/test_combat_component.gd
extends GutTest

# --- Constants ---
const CombatComponent = preload("res://src/entities/components/combat_component.gd")
const HealthComponent = preload("res://src/entities/components/health_component.gd")
const PlayerStateData = preload("res://src/entities/player/data/player_state_data.gd")
const DamageResult = preload("res://src/api/combat/damage_result.gd")
const CombatConfig = preload("res://src/data/combat_config.tres")
const Identifiers = preload("res://src/core/util/identifiers.gd")
const FakeObjectPool = preload("res://src/tests/fakes/fake_object_pool.gd")

# --- Test Internals ---
var _combat_component: CombatComponent
var _player_data: PlayerStateData
var _fake_object_pool: FakeObjectPool
var _pogo_bounce_was_requested: bool = false
var _mock_owner: CharacterBody2D

# --- Test Lifecycle ---


func before_each():
	_pogo_bounce_was_requested = false

	_mock_owner = CharacterBody2D.new()
	add_child(_mock_owner)

	_player_data = PlayerStateData.new()
	_player_data.config = CombatConfig

	_fake_object_pool = FakeObjectPool.new()
	add_child(_fake_object_pool)

	_combat_component = CombatComponent.new()
	_mock_owner.add_child(_combat_component)

	var dependencies = {"data_resource": _player_data, "object_pool": _fake_object_pool}
	_combat_component.setup(_mock_owner, dependencies)

	_combat_component.pogo_bounce_requested.connect(_on_pogo_bounce_requested)


func after_each():
	if (
		is_instance_valid(_combat_component)
		and _combat_component.pogo_bounce_requested.is_connected(_on_pogo_bounce_requested)
	):
		_combat_component.pogo_bounce_requested.disconnect(_on_pogo_bounce_requested)


# --- The Tests ---


func test_fire_shot_gets_instance_from_pool():
	var call_count_before = _fake_object_pool.get_call_count(Identifiers.Pools.PLAYER_SHOTS)
	_combat_component.fire_shot()
	var call_count_after = _fake_object_pool.get_call_count(Identifiers.Pools.PLAYER_SHOTS)

	assert_eq(
		call_count_after,
		call_count_before + 1,
		"fire_shot() should call get_instance on the pool exactly once."
	)


func test_trigger_pogo_on_enemy_emits_bounce_request():
	var mock_enemy = CharacterBody2D.new()
	mock_enemy.add_to_group(Identifiers.Groups.ENEMY)

	var mock_health = double(HealthComponent).new()
	# THE FIX: Explicitly name the component so `find_damageable` can discover it.
	mock_health.name = "HealthComponent"
	mock_enemy.add_child(mock_health)
	stub(mock_health, "apply_damage").to_return(DamageResult.new())

	add_child(mock_enemy)

	_player_data.is_pogo_attack = true

	var pogo_succeeded = _combat_component.trigger_pogo(mock_enemy)

	assert_true(pogo_succeeded, "trigger_pogo should return true when hitting a valid enemy.")
	assert_true(
		_pogo_bounce_was_requested,
		"pogo_bounce_requested signal should be emitted after a successful pogo."
	)

	mock_enemy.free()


func test_trigger_pogo_on_projectile_returns_it_to_pool() -> void:
	var mock_projectile = Node2D.new()
	mock_projectile.add_to_group(Identifiers.Groups.ENEMY_PROJECTILE)
	mock_projectile.set_meta("pool_name", Identifiers.Pools.TURRET_SHOTS)
	add_child(mock_projectile)

	_player_data.is_pogo_attack = true

	var return_count_before = _fake_object_pool.get_return_count(Identifiers.Pools.TURRET_SHOTS)
	_combat_component.trigger_pogo(mock_projectile)

	await get_tree().physics_frame

	var return_count_after = _fake_object_pool.get_return_count(Identifiers.Pools.TURRET_SHOTS)

	assert_eq(
		return_count_after,
		return_count_before + 1,
		"Pogoing a projectile should call return_instance on the pool."
	)


# --- Signal Handlers ---


func _on_pogo_bounce_requested():
	_pogo_bounce_was_requested = true