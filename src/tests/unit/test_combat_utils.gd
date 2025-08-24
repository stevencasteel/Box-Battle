# src/tests/unit/test_combat_utils.gd
extends GutTest

# --- Constants ---
const BaseEntity = preload("res://src/entities/base_entity.gd")
const HealthComponent = preload("res://src/entities/components/health_component.gd")
const IDamageable = preload("res://src/api/interfaces/IDamageable.gd")
const EntityArchetype = preload("res://src/entities/archetypes/entity_archetype.gd")

# --- Test Internals ---
var _combat_utils
var _mock_entity: BaseEntity
var _health_component: HealthComponent
var _non_damageable_child: Node

# --- Test Lifecycle ---

func before_all():
	_combat_utils = get_node("/root/CombatUtils")


func before_each():
	# Create a scene tree: MockEntity -> HealthComponent
	#                                -> NonDamageableChild
	_mock_entity = BaseEntity.new()
	# THE FIX: Provide a dummy archetype to prevent errors in _ready().
	_mock_entity.archetype = EntityArchetype.new()
	add_child_autofree(_mock_entity)

	_health_component = HealthComponent.new()
	_mock_entity.add_child(_health_component)
	_mock_entity._cache_components_by_type()

	_non_damageable_child = Node2D.new()
	_mock_entity.add_child(_non_damageable_child)


# --- The Tests ---

func test_find_damageable_returns_component_when_starting_from_entity():
	var result = _combat_utils.find_damageable(_mock_entity)
	assert_same(
		result,
		_health_component,
		"Should find the IDamageable component when starting from the entity root."
	)


func test_find_damageable_returns_component_when_starting_from_child():
	var result = _combat_utils.find_damageable(_non_damageable_child)
	assert_same(
		result,
		_health_component,
		"Should traverse up to the entity root and find the component when starting from a child."
	)


func test_find_damageable_returns_null_if_no_entity_ancestor_exists():
	var standalone_node = Node2D.new()
	add_child_autofree(standalone_node)
	var result = _combat_utils.find_damageable(standalone_node)
	assert_null(result, "Should return null when no BaseEntity ancestor is found.")