# res://src/tests/unit/test_health_component.gd
extends GutTest

# --- Constants ---
const HealthComponent = preload("res://src/entities/components/health_component.gd")
const PlayerStateData = preload("res://src/entities/player/data/player_state_data.gd")
const DamageInfo = preload("res://src/api/combat/damage_info.gd")
const CombatConfig = preload("res://src/data/combat_config.tres")
const VFXEffect = preload("res://src/core/data/effects/vfx_effect.gd")

# --- Test Internals ---
var _health_component: HealthComponent
var _player_data: PlayerStateData
var _mock_owner: CharacterBody2D
var _died_signal_was_emitted: bool
var _took_damage_signal_was_emitted: bool

# --- GUT Doubles & Autoload Management ---
var ServiceLocatorScript: GDScript
var FXManagerScript: GDScript
var sl_double: Node                    # ServiceLocator double (will be added under /root)
var fx_autoload_double: Node           # FXManager autoload double (will be added under /root)
var _orig_sl_autoload: Node            # original ServiceLocator node if present
var _orig_fx_autoload: Node            # original FXManager node if present

func before_all() -> void:
	# Load at runtime to avoid parse-time preloads / circulars
	ServiceLocatorScript = load("res://src/core/util/service_locator.gd")
	FXManagerScript = load("res://src/core/systems/fx_manager.gd")

func before_each() -> void:
	_died_signal_was_emitted = false
	_took_damage_signal_was_emitted = false

	# --- Prepare ServiceLocator double (unparented) ---
	sl_double = partial_double(ServiceLocatorScript).new()
	# We'll add sl_double under /root later.

	# --- Park and replace real FXManager autoload (if present) ---
	_orig_fx_autoload = get_tree().root.get_node_or_null("FXManager")
	if is_instance_valid(_orig_fx_autoload):
		_orig_fx_autoload.name = "__FXManager_Parked"

	# Create a GUT double for FXManager and add it into /root as the autoload replacement.
	# We intentionally use GUT's plain double so lifecycle/init isn't run.
	fx_autoload_double = double(FXManagerScript).new()
	stub(fx_autoload_double, "play_vfx").to_do_nothing()  # ensure operations called by SUT are inert
	fx_autoload_double.name = "FXManager"
	get_tree().root.add_child(fx_autoload_double)
	await get_tree().process_frame

	# --- Wire ServiceLocator's fx_manager reference to autoload double so both paths align ---
	sl_double.fx_manager = fx_autoload_double

	# --- Park and replace real ServiceLocator autoload (if present) ---
	_orig_sl_autoload = get_tree().root.get_node_or_null("ServiceLocator")
	if is_instance_valid(_orig_sl_autoload):
		_orig_sl_autoload.name = "__ServiceLocator_Parked"

	# Add ServiceLocator double to root so production code finds it by name
	sl_double.name = "ServiceLocator"
	get_tree().root.add_child(sl_double)
	await get_tree().process_frame

	# --- Setup test subject ---
	_mock_owner = CharacterBody2D.new()
	add_child_autofree(_mock_owner)

	_player_data = PlayerStateData.new()
	_player_data.config = CombatConfig
	_player_data.max_health = 10
	_player_data.health = 10

	_health_component = HealthComponent.new()
	_mock_owner.add_child(_health_component)

	# Provide a VFXEffect with a pool_key (defensive; shouldn't be used by double)
	var vfx = VFXEffect.new()
	vfx.pool_key = "test_hit_spark"

	var dependencies = {
		"data_resource": _player_data,
		"config": CombatConfig,
		"services": sl_double,
		"hit_spark_effect": vfx
	}
	_health_component.setup(_mock_owner, dependencies)

	_health_component.died.connect(func(): _died_signal_was_emitted = true)
	_health_component.took_damage.connect(func(_d, _r): _took_damage_signal_was_emitted = true)

func after_each() -> void:
	# --- Remove ServiceLocator double ---
	if is_instance_valid(sl_double):
		if sl_double.get_parent() == get_tree().root:
			sl_double.queue_free()
			await get_tree().process_frame

	# --- Remove FXManager autoload double ---
	if is_instance_valid(fx_autoload_double):
		if fx_autoload_double.get_parent() == get_tree().root:
			fx_autoload_double.queue_free()
			await get_tree().process_frame

	# --- Try to restore original FXManager autoload if it was parked ---
	if is_instance_valid(_orig_fx_autoload):
		# If something currently owns the name "FXManager", remove it first (shouldn't happen)
		var conflict_fx := get_tree().root.get_node_or_null("FXManager")
		if conflict_fx and conflict_fx != _orig_fx_autoload:
			conflict_fx.queue_free()
			await get_tree().process_frame

		if is_instance_valid(_orig_fx_autoload):
			_orig_fx_autoload.name = "FXManager"

	# --- Restore original ServiceLocator autoload if it was parked ---
	if is_instance_valid(_orig_sl_autoload):
		var conflict_sl := get_tree().root.get_node_or_null("ServiceLocator")
		if conflict_sl and conflict_sl != _orig_sl_autoload:
			conflict_sl.queue_free()
			await get_tree().process_frame

		if is_instance_valid(_orig_sl_autoload):
			_orig_sl_autoload.name = "ServiceLocator"

# --- Tests ---
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
