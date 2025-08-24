# src/tests/unit/test_input_component.gd
extends GutTest

# --- Constants ---
const InputComponent = preload("res://src/entities/components/input_component.gd")
const PlayerStateData = preload("res://src/entities/player/data/player_state_data.gd")
const CombatConfig = preload("res://src/data/combat_config.tres")
const GutInputSender = preload("res://addons/gut/input_sender.gd")

# --- Test Internals ---
var _input_component: InputComponent
var _input_sender: GutInputSender
var _mock_owner: CharacterBody2D

# --- Test Lifecycle ---
func before_all() -> void:
	# Create a single input sender that targets the global Input singleton.
	_input_sender = GutInputSender.new(Input)

func before_each():
	_mock_owner = CharacterBody2D.new()
	add_child_autofree(_mock_owner)

	_input_component = InputComponent.new()
	_mock_owner.add_child(_input_component)

	var dependencies = {
		"data_resource": PlayerStateData.new(),
		"config": CombatConfig
	}
	_input_component.setup(_mock_owner, dependencies)

func after_each() -> void:
	# Per GUT docs, always release held actions to prevent state leaking between tests.
	_input_sender.release_all()
	_input_sender.clear()
	await get_tree().process_frame

# --- The Tests ---
func test_move_axis_is_buffered_correctly() -> void:
	_input_sender.action_down("ui_right").wait_frames(1)
	await _input_sender.idle
	_input_component._physics_process(0.016)
	assert_eq(_input_component.buffer.get("move_axis"), 1.0, "Move axis should be 1.0 for 'ui_right'.")

	_input_sender.action_up("ui_right").action_down("ui_left").wait_frames(1)
	await _input_sender.idle
	_input_component._physics_process(0.016)
	assert_eq(_input_component.buffer.get("move_axis"), -1.0, "Move axis should be -1.0 for 'ui_left'.")

	_input_sender.action_up("ui_left").wait_frames(1)
	await _input_sender.idle
	_input_component._physics_process(0.016)
	assert_eq(_input_component.buffer.get("move_axis"), 0.0, "Move axis should be 0.0 when no key is pressed.")

func test_action_just_pressed_is_buffered_for_one_frame() -> void:
	_input_sender.action_down("ui_jump").wait_frames(1)
	await _input_sender.idle
	_input_component._physics_process(0.016)
	assert_true(_input_component.buffer.get("jump_just_pressed"), "'jump_just_pressed' should be true on the frame it is pressed.")

	# Advance one physics frame so the "just_pressed" condition expires.
	await wait_physics_frames(1)
	# note: physics frame will call _physics_process automatically, so no manual call needed
	assert_false(_input_component.buffer.get("jump_just_pressed", false), "'jump_just_pressed' should be false on subsequent frames.")

func test_action_released_is_buffered_for_one_frame() -> void:
	_input_sender.action_down("ui_attack").wait_frames(1)
	await _input_sender.idle
	_input_component._physics_process(0.016)

	_input_sender.action_up("ui_attack").wait_frames(1)
	await _input_sender.idle
	_input_component._physics_process(0.016)
	assert_true(_input_component.buffer.get("attack_released"), "'attack_released' should be true on the frame it is released.")

	# Advance one physics frame so the "attack_released" condition expires.
	await wait_physics_frames(1)
	assert_false(_input_component.buffer.get("attack_released", false), "'attack_released' should be false on subsequent frames.")

func test_action_held_persists_across_frames() -> void:
	_input_sender.action_down("ui_jump").wait_frames(1)
	await _input_sender.idle
	_input_component._physics_process(0.016)
	assert_true(_input_component.buffer.get("jump_held"), "'jump_held' should be true on the first frame.")

	_input_component._physics_process(0.016)
	assert_true(_input_component.buffer.get("jump_held"), "'jump_held' should remain true on subsequent frames.")

	_input_sender.action_up("ui_jump").wait_frames(1)
	await _input_sender.idle
	_input_component._physics_process(0.016)
	assert_false(_input_component.buffer.get("jump_held", false), "'jump_held' should be false after being released.")