# src/api/interfaces/component_interface.gd
#
# This script defines the formal "contract" or "interface" for all components
# in the project (HealthComponent, CombatComponent, etc.).
# By extending this class, each component guarantees it will have a consistent
# API for initialization and cleanup.
class_name ComponentInterface
extends Node

# The standardized initialization method for all components.
# - owner: The node this component is attached to (e.g., the Player).
# - config: A Resource containing static configuration data.
# - services: A container for any global services the component needs (e.g., EventBus).
func setup(owner: Node, config: Resource = null, services = null) -> void:
	pass

# The standardized cleanup method for all components.
# This can be used to disconnect signals or free resources.
func teardown() -> void:
	pass
