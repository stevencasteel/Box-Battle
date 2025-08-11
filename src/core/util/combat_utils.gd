# src/core/util/combat_utils.gd
# A collection of helper functions for combat-related logic.
# This script extends Node to function as an autoload singleton.
extends Node

# Traverses up the scene tree from a given node to find the first
# node that has a HealthComponent child. This is robust against hitting
# child colliders or areas.
func find_health_component(from_node: Node) -> HealthComponent:
	var current_node = from_node
	while is_instance_valid(current_node):
		# First, check if the current node has the component as a direct child.
		var hc = current_node.get_node_or_null("HealthComponent")
		if hc and hc is HealthComponent:
			return hc
		# If not, move up to the parent and check again.
		current_node = current_node.get_parent()
	
	# If we reach the top of the tree without finding it, return null.
	return null
