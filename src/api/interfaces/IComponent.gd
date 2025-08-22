# src/api/interfaces/IComponent.gd
## The conceptual "interface" for all entity components.
##
## This script defines the formal contract that components like [HealthComponent]
## and [CombatComponent] adhere to. It is not meant to be instanced directly.
class_name IComponent
extends Node

# --- Virtual Methods ---


## Initializes the component and injects its dependencies.
##
## [param p_owner]: A reference to the node that owns this component.
## [param p_dependencies]: A dictionary of any other required nodes or resources.
func setup(_p_owner: Node, _p_dependencies: Dictionary = {}) -> void:
	pass


## Called when the owner is being destroyed to clean up connections and references.
func teardown() -> void:
	pass
