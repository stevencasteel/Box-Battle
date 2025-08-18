# src/tests/unit/test_input_component.gd
extends GutTest

# --- Constants ---
const Player = preload("res://src/entities/player/player.tscn")
const InputComponent = preload("res://src/entities/components/input_component.gd")
const CombatConfig = preload("res://data/combat_config.tres")

# --- Test Internals ---
var _player: Player
var _input_component: InputComponent

# --- Test Lifecycle ---

func before_each():
	# We need a real Player to host the component.
	_player = Player.instantiate()
	add_child(_player)
	_input_component = _player.get_node("InputComponent")
	
	# Manually call setup since we are not running the full game scene.
	_input_component.setup(_player, {
		"data_resource": _player.p_data,
		"state_machine": _player.state_machine,
		"config": CombatConfig
	})
	
	await get_tree().process_frame

func after_each():
	# Ensure all simulated actions are released to prevent state leakage between tests.
	Input.action_release("ui_right")
	Input.action_release("ui_attack")

	if is_instance_valid(_player):
		_player.free()

# --- The Tests ---

func test_move_axis_is_buffered_correctly():
	# Simulate pressing the "right" action.
	Input.action_press("ui_right")
	# Manually call the component's physics process to update its buffer.
	_input_component._physics_process(0.016)
	
	assert_eq(_input_component.buffer.get("move_axis"), 1.0, "Move axis should be 1.0 when 'ui_right' is pressed.")
	
	# Simulate releasing the action.
	Input.action_release("ui_right")
	_input_component._physics_process(0.016)
	
	assert_eq(_input_component.buffer.get("move_axis"), 0.0, "Move axis should be 0.0 when 'ui_right' is released.")

func test_action_just_pressed_is_buffered_for_one_frame():
	# THE FIX: Simulate pressing the correct action ("ui_attack") to match the assertion.
	Input.action_press("ui_attack")
	_input_component._physics_process(0.016)
	
	assert_true(_input_component.buffer.get("attack_just_pressed", false), "attack_just_pressed should be true on the frame it is pressed.")
	
	# THE FIX: Yield to the engine to allow the Input singleton to update its state.
	await get_tree().process_frame
	_input_component._physics_process(0.016)
	
	assert_false(_input_component.buffer.get("attack_just_pressed", false), "attack_just_pressed should be false on subsequent frames.")
	
	Input.action_release("ui_attack")

func test_action_released_is_buffered_for_one_frame():
	Input.action_press("ui_attack")
	_input_component._physics_process(0.016) # Frame 1: Pressed
	await get_tree().process_frame
	
	_input_component._physics_process(0.016) # Frame 2: Held
	assert_false(_input_component.buffer.get("attack_released", false), "attack_released should be false while the action is held.")
	
	# Now, simulate the release.
	Input.action_release("ui_attack")
	_input_component._physics_process(0.016) # Frame 3: Released
	assert_true(_input_component.buffer.get("attack_released", false), "attack_released should be true on the frame it is released.")
	
	# THE FIX: Yield to the engine to allow the Input singleton to update its state.
	await get_tree().process_frame
	_input_component._physics_process(0.016) # Frame 4: After release
	
	assert_false(_input_component.buffer.get("attack_released", false), "attack_released should be false on the frame after it is released.")