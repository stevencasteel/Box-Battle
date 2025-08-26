# src/api/combat/melee_attack_data.gd
@tool
## A data resource that defines the properties of a single melee attack.
## This allows for creating varied attacks without changing code.
class_name MeleeAttackData
extends Resource

@export_group("Core Properties")
## The Shape2D resource that defines the hitbox area.
@export var shape: Shape2D
## The local offset from the entity's origin where the hitbox should be centered.
@export var offset: Vector2 = Vector2.ZERO
## The base damage dealt by the attack.
@export var damage_amount: int = 1

@export_group("Timing")
## The duration in seconds the hitbox remains active.
@export_range(0.05, 1.0, 0.01) var duration: float = 0.15
## The duration in seconds of the telegraph visual before the attack becomes active.
@export_range(0.0, 2.0, 0.05) var telegraph_duration: float = 0.3

@export_group("Feedback & Juice")
## The duration in seconds of hit-stop to apply on a successful hit.
@export_range(0.0, 0.5, 0.01) var hit_stop_duration: float = 0.0
## The screen shake effect to trigger on a successful hit.
@export var screen_shake_effect: ScreenShakeEffect
## The VFX to spawn at the impact point on a successful hit.
@export var hit_spark_effect: VFXEffect
