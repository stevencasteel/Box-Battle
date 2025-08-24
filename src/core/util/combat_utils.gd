# src/core/util/combat_utils.gd
## An autoloaded singleton containing static helper functions for combat logic.
extends Node

## Traverses up the scene tree from a given node to find its root BaseEntity.
func find_entity_root(from_node: Node) -> BaseEntity:
	if not is_instance_valid(from_node):
		return null
	
	var current_node = from_node
	while is_instance_valid(current_node):
		if current_node is BaseEntity:
			return current_node
		current_node = current_node.get_parent()
		
	return null

## Finds the IDamageable component on a target node by first finding the
## target's entity root, then asking for the component.
func find_damageable(from_node: Node) -> IDamageable:
	var entity: BaseEntity = find_entity_root(from_node)
	if is_instance_valid(entity):
		return entity.get_component(IDamageable)
	
	# Fallback for non-entity damageable nodes (e.g., a simple damageable prop)
	if from_node is IDamageable:
		return from_node
		
	return null