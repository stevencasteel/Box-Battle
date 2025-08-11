# src/api/interfaces/i_damageable.gd
#
# The "Interface" contract for any object in the game that can take damage.
# Any script that inherits from this must implement the apply_damage function.
#
# In GDScript, this is a conceptual interface. We check for compliance
# by using `target.has_method("apply_damage")`.
extends Node

# --- The Contract ---
#
# func apply_damage(damage_amount: int, damage_source: Node = null, bypass_invincibility: bool = false) -> Dictionary:
#   must return a dictionary, e.g., {"was_damaged": bool, "knockback_velocity": Vector2}
#
