# src/core/boot/boot_manager.gd
## A stateless utility responsible for orchestrating the initialization of
## core game systems in a predictable order.
class_name BootManager
extends RefCounted

## Finds all necessary autoloads and calls their initialization methods.
static func initialize_systems() -> void:
	var scene_tree: SceneTree = Engine.get_main_loop() as SceneTree
	if not is_instance_valid(scene_tree):
		push_error("BootManager: Could not get valid SceneTree.")
		return

	var root_node: Node = scene_tree.root
	if not is_instance_valid(root_node):
		push_error("BootManager: Could not get SceneTree's root node.")
		return

	# Tell the ObjectPool to create all its initial instances.
	var object_pool: Node = root_node.get_node("/root/ObjectPool")
	if is_instance_valid(object_pool) and object_pool.has_method("initialize"):
		object_pool.initialize()

	# TODO: Add other systems here as needed (e.g., pre-caching assets).