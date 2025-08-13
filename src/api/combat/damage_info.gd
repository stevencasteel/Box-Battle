# src/api/combat/damage_info.gd
# A typed Resource to define a complete damage event.
class_name DamageInfo
extends Resource

@export var amount: int = 1
var source_node: Node = null # FIX: Removed @export. This is a runtime-only property.
@export var bypass_invincibility: bool = false
