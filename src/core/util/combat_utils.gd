# src/core/util/combat_utils.gd
## An autoloaded singleton containing static helper functions for combat logic.
extends Node

# --- Static Functions ---


## Traverses up the scene tree from a given node to find the first node that
## implements the IDamageable interface (i.e., has an `apply_damage` method).
## This is the canonical way to find a valid damage target from a collision.
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
