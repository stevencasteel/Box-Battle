# src/api/combat/damage_info.gd
## A typed Resource that defines a complete damage event.
class_name DamageInfo
extends Resource

# --- Editor Properties ---
@export var amount: int = 1
@export var bypass_invincibility: bool = false

# --- Member Variables ---
## A reference to the node that was the source of the damage.
var source_node: Node = null
## The global position where the impact occurred.
var impact_position: Vector2 = Vector2.ZERO
## The normal vector of the surface that was hit, used for directing VFX.
var impact_normal: Vector2 = Vector2.ZERO
