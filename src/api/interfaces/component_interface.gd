# src/api/interfaces/component_interface.gd
#
# This script defines the formal "contract" or "interface" for all components
# in the project (HealthComponent, CombatComponent, etc.).
class_name ComponentInterface
extends Node

# CORRECTED: Added underscore to unused parameter `p_owner`.
func setup(_p_owner: Node, _config: Resource = null, _services = null) -> void:
	pass

func teardown() -> void:
	pass
