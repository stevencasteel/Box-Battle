# src/tests/unit/test_combat_utils.gd
extends GutTest

# --- Constants ---
# We no longer preload CombatUtils here, as we'll get it from the tree.
const HealthComponent = preload("res://src/entities/components/health_component.gd")

# --- Test Internals ---
var _combat_utils # Will hold the instance of the singleton
var _root: Node
var _parent_with_health_component: Node
var _damageable_child: HealthComponent
var _non_damageable_grandchild: Node

# --- Test Lifecycle ---

func before_all():
	# Get the singleton instance from the SceneTree once.
	# This requires the test to run in the context of a scene, which GUT provides.
	_combat_utils = get_node("/root/CombatUtils")


func before_each():
	# Create a simple scene tree for testing tree traversal.
	# Root -> ParentWithHealthComponent -> NonDamageableGrandchild
	# The HealthComponent is attached to the Parent.
	_root = Node.new()
	add_child_autofree(_root) # gut will free this node after the test

	_parent_with_health_component = Node2D.new()
	_parent_with_health_component.name = "Parent"
	_root.add_child(_parent_with_health_component)

	_damageable_child = HealthComponent.new()
	_damageable_child.name = "HealthComponent" # This name is important for some lookups
	_parent_with_health_component.add_child(_damageable_child)

	_non_damageable_grandchild = Node2D.new()
	_non_damageable_grandchild.name = "Grandchild"
	_parent_with_health_component.add_child(_non_damageable_grandchild)


# --- The Tests ---

func test_find_damageable_returns_correct_node_when_starting_from_parent():
	# Scenario 1: We start searching from a node that has a damageable component as a child.
	# The function should find the HealthComponent on its child.
	var result = _combat_utils.find_damageable(_parent_with_health_component)
	assert_same(
		result,
		_damageable_child,
		"Should find the HealthComponent node when starting from its parent."
	)


func test_find_damageable_returns_ancestor_if_child_is_not_damageable():
	# Scenario 2: We start searching from a node that is not damageable itself.
	# The function should traverse UP the tree and find the HealthComponent on its parent.
	var result = _combat_utils.find_damageable(_non_damageable_grandchild)
	assert_same(
		result,
		_damageable_child,
		"Should traverse up and find the HealthComponent on the parent."
	)


func test_find_damageable_returns_null_if_no_damageable_ancestor_exists():
	# Scenario 3: We create a node that is not in our test hierarchy.
	# The function should find nothing and return null.
	var standalone_node = Node2D.new()
	add_child_autofree(standalone_node)
	var result = _combat_utils.find_damageable(standalone_node)
	assert_null(result, "Should return null when no damageable parent is found.")