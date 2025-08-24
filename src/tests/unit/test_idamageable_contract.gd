# src/tests/unit/test_idamageable_contract.gd
extends GutTest

# --- Constants & Preloads ---
const HealthComponent = preload("res://src/entities/components/health_component.gd")
const FakeDamageable = preload("res://src/tests/fakes/fake_damageable.gd")
const PlayerStateData = preload("res://src/entities/player/data/player_state_data.gd")
const DamageInfo = preload("res://src/api/combat/damage_info.gd")
const FakeServiceLocator = preload("res://src/tests/fakes/fake_service_locator.gd")

# --- Test Internals ---
var _mock_owner: CharacterBody2D # THE FIX: Changed type from Node
var _fake_services: FakeServiceLocator

# --- Test Lifecycle ---
func before_each():
	_mock_owner = CharacterBody2D.new() # THE FIX: Instantiate the correct type
	add_child_autofree(_mock_owner)
	
	_fake_services = FakeServiceLocator.new()
	add_child_autofree(_fake_services)

# --- The Contract Test Suite ---

func _run_contract_tests(damageable: IDamageable, name: String) -> void:
	# Contract Rule 1: It must return a valid DamageResult object.
	var result = damageable.apply_damage(DamageInfo.new())
	assert_is(result, DamageResult, "Contract Failure (%s): apply_damage must return a DamageResult." % name)
	
	# Contract Rule 2: It must not crash when given a null DamageInfo.
	var null_result = damageable.apply_damage(null)
	assert_is(null_result, DamageResult, "Contract Failure (%s): Must handle null DamageInfo gracefully." % name)


# --- The Tests ---

func test_health_component_fulfills_contract():
	var health_comp = HealthComponent.new()
	_mock_owner.add_child(health_comp)
	
	var data = PlayerStateData.new()
	data.max_health = 10
	var deps = {
		"data_resource": data,
		"config": preload("res://src/data/combat_config.tres"),
		"services": _fake_services,
		"hit_spark_effect": preload("res://src/core/data/effects/player_hit_spark_effect.tres")
	}
	# THE FIX: Pass the correctly typed owner node
	health_comp.setup(_mock_owner, deps)
	
	_run_contract_tests(health_comp, "HealthComponent")


func test_fake_damageable_fulfills_contract():
	var fake_damageable = FakeDamageable.new()
	_mock_owner.add_child(fake_damageable)
	
	_run_contract_tests(fake_damageable, "FakeDamageable")