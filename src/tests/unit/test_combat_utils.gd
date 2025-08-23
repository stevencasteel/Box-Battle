# src/tests/unit/test_combat_utils.gd
extends GutTest

# --- Constants ---
const CombatUtils = preload("res://src/core/util/combat_utils.gd")
const HealthComponent = preload("res://src/entities/components/health_component.gd")

# --- Test Internals ---
var _root: Node
var _parent: Node
var _damageable_child: HealthComponent  # This IS the damageable node now
var _non_damageable_grandchild: Node

# --- Test Lifecycle ---


func before_each():
	# Create a simple scene tree for testing tree traversal.
	# Root -> Parent -> DamageableChild (HealthComponent) -> NonDamageableGrandchild
	_root = Node.new()
	add_child(_root)

	_parent = Node2D.new()
	_parent.name = "Parent"
	_root.add_child(_parent)

	_damageable_child = HealthComponent.new()
	_damageable_child.name = "HealthComponent"
	_parent.add_child(_damageable_child)

	_non_damageable_grandchild = Node2D.new()
	_non_damageable_grandchild.name = "NonDamageableGrandchild"
	_damageable_child.add_child(_non_damageable_grandchild)


func test_find_damageable_returns_self_if_damageable():
	var result = CombatUtils.find_damageable(_damageable_child)
	assert_same(result, _damageable_child, "Should return the node itself if it's damageable.")


func test_find_damageable_returns_ancestor_if_child_is_not_damageable():
	var result = CombatUtils.find_damageable(_non_damageable_grandchild)
	assert_same(
		result, _damageable_child, "Should traverse up and find the ancestor HealthComponent."
	)


func test_find_damageable_returns_null_if_no_damageable_ancestor_exists():
	var standalone_node = autofree(Node2D.new())
	var result = CombatUtils.find_damageable(standalone_node)
	assert_null(result, "Should return null when no damageable parent is found.")
