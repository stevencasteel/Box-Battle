# src/tests/unit/test_input_component.gd
extends GutTest

# --- Constants ---
const Player = preload("res://src/entities/player/player.tscn")
const InputComponent = preload("res://src/entities/components/input_component.gd")
const CombatConfig = preload("res://src/data/combat_config.tres")

# --- Test Internals ---
var _player: Player
var _input_component: InputComponent

# --- Test Lifecycle ---


func before_each():
	_player = Player.instantiate()
	if _player.has_method("inject_dependencies"):
		_player.inject_dependencies(
			{
				"object_pool": get_node("/root/ObjectPool"),
				"fx_manager": get_node("/root/FXManager"),
				"event_bus": get_node("/root/EventBus")
			}
		)
	add_child(_player)
	_input_component = _player.get_component(InputComponent)

	_input_component.setup(
		_player,
		{
			"data_resource": _player.entity_data,
			"state_machine": _player.get_component(BaseStateMachine),
			"config": CombatConfig
		}
	)

	await get_tree().process_frame


func after_each():
	Input.action_release("ui_right")
	Input.action_release("ui_attack")

	if is_instance_valid(_player):
		_player.free()


# --- The Tests ---


func test_move_axis_is_buffered_correctly():
	Input.action_press("ui_right")
	_input_component._physics_process(0.016)

	assert_eq(
		_input_component.buffer.get("move_axis"),
		1.0,
		"Move axis should be 1.0 when 'ui_right' is pressed."
	)

	Input.action_release("ui_right")
	_input_component._physics_process(0.016)

	assert_eq(
		_input_component.buffer.get("move_axis"),
		0.0,
		"Move axis should be 0.0 when 'ui_right' is released."
	)


func test_action_just_pressed_is_buffered_for_one_frame():
	Input.action_press("ui_attack")
	_input_component._physics_process(0.016)

	assert_true(
		_input_component.buffer.get("attack_just_pressed", false),
		"attack_just_pressed should be true on the frame it is pressed."
	)

	await get_tree().process_frame
	_input_component._physics_process(0.016)

	assert_false(
		_input_component.buffer.get("attack_just_pressed", false),
		"attack_just_pressed should be false on subsequent frames."
	)

	Input.action_release("ui_attack")


func test_action_released_is_buffered_for_one_frame():
	Input.action_press("ui_attack")
	_input_component._physics_process(0.016)
	await get_tree().process_frame

	_input_component._physics_process(0.016)
	assert_false(
		_input_component.buffer.get("attack_released", false),
		"attack_released should be false while the action is held."
	)

	Input.action_release("ui_attack")
	_input_component._physics_process(0.016)
	assert_true(
		_input_component.buffer.get("attack_released", false),
		"attack_released should be true on the frame it is released."
	)

	await get_tree().process_frame
	_input_component._physics_process(0.016)

	assert_false(
		_input_component.buffer.get("attack_released", false),
		"attack_released should be false on the frame after it is released."
	)
