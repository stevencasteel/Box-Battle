# src/api/interfaces/component_interface.gd
#
# This script defines the formal "contract" or "interface" for all components
# in the project (HealthComponent, CombatComponent, etc.).
class_name ComponentInterface
extends Node

# The setup function is now more flexible.
# It takes the owner and an optional dictionary for any other dependencies.
# MODIFIED: Prefixed parameters with an underscore to silence UNUSED_PARAMETER
# warnings, as this base implementation is intentionally empty.
func setup(_p_owner: Node, _p_dependencies: Dictionary = {}) -> void:
	pass

func teardown() -> void:
	pass
