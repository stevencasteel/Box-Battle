# src/tests/unit/test_health_component.gd
extends GutTest

# --- Constants ---
const HealthComponent = preload("res://src/entities/components/health_component.gd")
const PlayerStateData = preload("res://src/entities/player/data/player_state_data.gd")
const DamageInfo = preload("res://src/api/combat/damage_info.gd")
const CombatConfig = preload("res://src/data/combat_config.tres")
const VFXEffect = preload("res://src/core/data/effects/vfx_effect.gd")
const FakeServiceLocator = preload("res://src/tests/fakes/fake_service_locator.gd")
const IFXManager = preload("res://src/api/interfaces/IFXManager.gd")

# --- Test Internals ---
var _health_component: HealthComponent
var _player_data: PlayerStateData
var _mock_owner: CharacterBody2D
var _died_signal_was_emitted: bool
var _took_damage_signal_was_emitted: bool
var _fake_services: FakeServiceLocator
var _fx_manager_double

func before_each() -> void:
	_died_signal_was_emitted = false
	_took_damage_signal_was_emitted = false

	# 1. Create a double for the FXManager interface
	_fx_manager_double = double(IFXManager).new()
	stub(_fx_manager_double, "play_vfx").to_do_nothing()
	add_child_autofree(_fx_manager_double)

	# 2. Create our robust FakeServiceLocator and inject the double
	_fake_services = FakeServiceLocator.new()
	_fake_services.mock_fx_manager = _fx_manager_double
	add_child_autofree(_fake_services)

	# 3. Setup test subject
	_mock_owner = CharacterBody2D.new()
	add_child_autofree(_mock_owner)

	_player_data = PlayerStateData.new()
	_player_data.config = CombatConfig
	_player_data.max_health = 10
	_player_data.health = 10

	_health_component = HealthComponent.new()
	_mock_owner.add_child(_health_component)

	var vfx = VFXEffect.new()
	vfx.pool_key = "test_hit_spark"

	var dependencies = {
		"data_resource": _player_data,
		"config": CombatConfig,
		"services": _fake_services,
		"hit_spark_effect": vfx
	}
	_health_component.setup(_mock_owner, dependencies)

	_health_component.died.connect(func(): _died_signal_was_emitted = true)
	_health_component.took_damage.connect(func(_d, _r): _took_damage_signal_was_emitted = true)


# --- The Tests ---
func test_initial_health_is_max_health():
	assert_eq(_player_data.health, 10, "Health should be max health at start.")

func test_apply_damage_reduces_health_and_emits_signal():
	var damage_info = DamageInfo.new()
	damage_info.amount = 3
	var result = _health_component.apply_damage(damage_info)

	assert_true(result.was_damaged, "Result object should indicate damage was taken.")
	assert_eq(_player_data.health, 7, "Health should be reduced by 3.")
	assert_true(_took_damage_signal_was_emitted, "'took_damage' signal should have been emitted.")

func test_cannot_take_damage_when_invincible():
	var damage_info = DamageInfo.new()
	damage_info.amount = 1
	_health_component.apply_damage(damage_info)

	assert_true(_health_component.is_invincible(), "Component should be invincible after first hit.")

	_took_damage_signal_was_emitted = false
	var result = _health_component.apply_damage(damage_info)

	assert_false(result.was_damaged, "Should not be able to take damage while invincible.")
	assert_eq(_player_data.health, 9, "Health should not have changed on second hit.")
	assert_false(_took_damage_signal_was_emitted, "'took_damage' should not be emitted when invincible.")

func test_died_signal_emitted_at_zero_health():
	var damage_info = DamageInfo.new()
	damage_info.amount = 10
	_health_component.apply_damage(damage_info)

	assert_true(_died_signal_was_emitted, "The 'died' signal should have been emitted.")
	assert_eq(_player_data.health, 0, "Health should be 0 after lethal damage.")