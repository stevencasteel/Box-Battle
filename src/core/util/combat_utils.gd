# src/core/util/combat_utils.gd
# A collection of static helper functions for combat-related logic.
extends Node

# Finds any node that can be damaged by checking for the `apply_damage` method,
# which is our conceptual interface. It returns the node that has the method.
func find_damageable(from_node: Node) -> Node:
	var current_node = from_node
	while is_instance_valid(current_node):
		# Check if the node itself implements the IDamageable interface.
		if current_node.has_method("apply_damage"):
			return current_node
			
		# HealthComponent is the primary implementer of our interface.
		# This provides a direct path for performance.
		var hc = current_node.get_node_or_null("HealthComponent")
		if hc and hc.has_method("apply_damage"):
			return hc

		# If not, move up to the parent and check again.
		current_node = current_node.get_parent()
	
	return null
