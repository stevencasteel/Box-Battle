# src/tests/unit/test_combat_utils.gd
extends GutTest

# --- Constants ---
const CombatUtils = preload("res://src/core/util/combat_utils.gd")
const HealthComponent = preload("res://src/entities/components/health_component.gd")

# --- Test Internals ---
var _root: Node
var _damageable_parent: Node
var _non_damageable_child: Node

# --- Test Lifecycle ---

func before_each():
	# Create a simple scene tree for testing tree traversal.
	# Root -> DamageableParent -> NonDamageableChild
	_root = Node.new()
	add_child(_root) # The test runner will manage this node.
	
	_damageable_parent = Node2D.new()
	_damageable_parent.name = "DamageableParent"
	
	# THE FIX: Create the component, give it a name, then add it as a child.
	var health_comp = HealthComponent.new()
	health_comp.name = "HealthComponent"
	_damageable_parent.add_child(autofree(health_comp))
	
	_root.add_child(_damageable_parent)
	
	_non_damageable_child = Node2D.new()
	_non_damageable_child.name = "NonDamageableChild"
	_damageable_parent.add_child(_non_damageable_child)

func test_find_damageable_returns_self_if_damageable():
	# This test is now inverted: the component, not the parent, is the damageable node.
	var health_comp = _damageable_parent.get_node("HealthComponent")
	var result = CombatUtils.find_damageable(health_comp)
	assert_same(result, health_comp, "Should return the component itself if it's damageable.")

func test_find_damageable_returns_parent_component_if_child_is_not_damageable():
	var health_comp = _damageable_parent.get_node("HealthComponent")
	var result = CombatUtils.find_damageable(_non_damageable_child)
	assert_same(result, health_comp, "Should traverse up and find the parent's HealthComponent.")

func test_find_damageable_returns_null_if_no_damageable_ancestor_exists():
	var standalone_node = autofree(Node2D.new())
	var result = CombatUtils.find_damageable(standalone_node)
	assert_null(result, "Should return null when no damageable parent is found.")