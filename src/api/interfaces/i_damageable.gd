# src/api/interfaces/i_damageable.gd
#
# The "Interface" contract for any object that can take damage. This is a
# conceptual interface and is not meant to be extended directly. It serves as
# project documentation for the damage system's API.
#
# We check for compliance by using `target.has_method("apply_damage")`.
class_name IDamageable

# --- The Contract ---
#
# func apply_damage(damage_info: DamageInfo) -> DamageResult:
#   Must accept a DamageInfo resource.
#   Must return a DamageResult resource.
#