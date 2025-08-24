# src/api/interfaces/IDamageable.gd
## The "interface" contract for any component that can take damage.
## By extending IComponent, it ensures that any damageable object
## also respects the standard component lifecycle (setup, teardown).
class_name IDamageable
extends IComponent

# --- The Contract (Virtual Method) ---

## Applies damage to the object.
## [param damage_info]: A [DamageInfo] resource detailing the damage event.
## [return]: A [DamageResult] resource indicating the outcome.
func apply_damage(_damage_info: DamageInfo) -> DamageResult:
	push_warning("IDamageable.apply_damage() was called but not overridden by the implementer.")
	return DamageResult.new()
