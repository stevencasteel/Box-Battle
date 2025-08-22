# src/api/interfaces/IDamageable.gd
## The "interface" contract for any object that can take damage.
class_name IDamageable
extends Node

# --- The Contract ---


## Applies damage to the object.
## [param damage_info]: A [DamageInfo] resource detailing the damage event.
## [return]: A [DamageResult] resource indicating the outcome.
func apply_damage(_damage_info: DamageInfo) -> DamageResult:
	# This is a virtual method and should be overridden by implementers.
	return DamageResult.new()
