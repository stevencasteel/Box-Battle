# src/core/util/combat_utils.gd
# A collection of static helper functions for combat-related logic.
extends Node

# Finds any node that can be damaged by recursively searching up the scene tree.
# This remains the single source of truth for finding a damageable target.
static func find_damageable(from_node: Node) -> Node:
	if not is_instance_valid(from_node):
		return null
		
	var current_node = from_node
	while is_instance_valid(current_node):
		if current_node.has_method("apply_damage"):
			return current_node
		
		# HealthComponent is the primary implementer, check for it directly.
		var hc = current_node.get_node_or_null("HealthComponent")
		if is_instance_valid(hc) and hc.has_method("apply_damage"):
			return hc

		current_node = current_node.get_parent()
	
	return null