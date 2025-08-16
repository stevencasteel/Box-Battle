# src/entities/components/armor_component.gd
@tool
## A simple component that manages an "armored" or invulnerable state.
##
## When active, other components can query its [member is_armored] property to
## determine if damage should be ignored.
class_name ArmorComponent
extends ComponentInterface

## If true, the entity is invulnerable to damage.
var is_armored: bool = false

# --- Public Methods ---

## Activates the armored state.
func activate() -> void:
	is_armored = true

## Deactivates the armored state.
func deactivate() -> void:
	is_armored = false