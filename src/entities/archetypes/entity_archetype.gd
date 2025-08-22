# src/entities/archetypes/entity_archetype.gd
@tool
## A data resource that defines the component-based structure of an entity.
##
## This acts as a blueprint, telling a BaseEntity which components to instance
## and attach to itself at runtime.
class_name EntityArchetype
extends Resource

## An array of PackedScene files, where each scene is a component
## (e.g., HealthComponent.tscn, InputComponent.tscn).
@export var components: Array[PackedScene] = []
