# src/entities/components/armor_component.gd
#
# A simple component that manages an "armored" state. When active, it can
# be queried by other components (like HealthComponent) to determine if
# damage should be ignored.
class_name ArmorComponent
extends Node

var is_armored: bool = false

func activate():
	is_armored = true
	# Optional: Add visual feedback here later, like changing the boss's color.
	print("VERIFICATION: ArmorComponent ACTIVATED.")

func deactivate():
	is_armored = false
	# Optional: Revert visual feedback here.
	print("VERIFICATION: ArmorComponent DEACTIVATED.")
