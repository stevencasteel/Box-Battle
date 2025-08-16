# src/api/combat/damage_info.gd
## A typed Resource that defines a complete damage event.
class_name DamageInfo
extends Resource

# --- Editor Properties ---
@export var amount: int = 1
@export var bypass_invincibility: bool = false

# --- Member Variables ---
## A reference to the node that was the source of the damage.
## This is a runtime-only property and should not be set in the editor.
var source_node: Node = null