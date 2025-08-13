# src/api/combat/damage_result.gd
# A typed Resource for the return value of apply_damage.
class_name DamageResult
extends Resource

@export var was_damaged: bool = false
@export var knockback_velocity: Vector2 = Vector2.ZERO
