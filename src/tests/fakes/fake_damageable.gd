# src/tests/fakes/fake_damageable.gd
## A test-double (fake) that implements the IDamageable interface for use in unit tests.
## It records damage events and allows tests to inspect what happened.
class_name FakeDamageable
extends IDamageable

# --- Test Seams & Recorders ---
var was_damage_applied: bool = false
var last_damage_info: DamageInfo = null
var return_result: DamageResult = DamageResult.new() # Pre-configured result to return


func setup(_p_owner: Node, _p_dependencies: Dictionary = {}) -> void:
	# IComponent contract requires this method.
	pass


func teardown() -> void:
	# IComponent contract requires this method.
	pass


func apply_damage(damage_info: DamageInfo) -> DamageResult:
	was_damage_applied = true
	last_damage_info = damage_info
	return return_result


## Resets the state of the fake for the next test.
func reset() -> void:
	was_damage_applied = false
	last_damage_info = null
	return_result = DamageResult.new()
