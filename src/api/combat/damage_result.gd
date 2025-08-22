# src/api/combat/damage_result.gd
## A typed Resource for the return value of an `apply_damage` call.
class_name DamageResult
extends Resource

# --- Member Variables ---
## True if damage was successfully applied.
var was_damaged: bool = false
## The calculated knockback velocity that should be applied to the target.
var knockback_velocity: Vector2 = Vector2.ZERO
