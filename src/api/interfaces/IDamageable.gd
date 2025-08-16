# src/api/interfaces/IDamageable.gd
## The conceptual "interface" for any object that can take damage.
##
## This script is not meant to be extended directly. It serves as project
## documentation for the damage system's API. A node is considered "damageable"
## if it implements the methods defined in this contract. We check for compliance
## using [code]target.has_method("apply_damage")[/code].
class_name IDamageable

# --- The Contract ---

## Applies damage to the object.
##
## [param damage_info]: A [DamageInfo] resource detailing the damage event.
## [return]: A [DamageResult] resource indicating the outcome.
# func apply_damage(damage_info: DamageInfo) -> DamageResult:
#     pass