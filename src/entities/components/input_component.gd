# src/entities/components/input_component.gd
@tool
## A component that centralizes all raw input polling.
##
## It reads from Godot's Input singleton each frame and populates a buffer
## dictionary. Other components and states read from this buffer, decoupling
## them from the global Input singleton.
class_name InputComponent
extends IComponent

# --- Member Variables ---
var owner_node: CharacterBody2D
var p_data: PlayerStateData
var state_machine: BaseStateMachine
var _config: CombatConfig # Internal reference to the injected config

## A buffer dictionary populated each frame with the current input state.
var buffer: Dictionary = {}

# --- Godot Lifecycle Methods ---

func _physics_process(_delta: float) -> void:
	# 1. Clear the buffer at the start of the frame.
	buffer.clear()

	# 2. Populate the buffer with the current input state.
	buffer["move_axis"] = Input.get_axis("ui_left", "ui_right")

	buffer["up"] = Input.is_action_pressed("ui_up")
	buffer["down"] = Input.is_action_pressed("ui_down")

	buffer["jump_pressed"] = Input.is_action_just_pressed("ui_jump")
	buffer["jump_released"] = Input.is_action_just_released("ui_jump")

	buffer["attack_pressed"] = Input.is_action_pressed("ui_attack")
	buffer["attack_just_pressed"] = Input.is_action_just_pressed("ui_attack")
	buffer["attack_released"] = Input.is_action_just_released("ui_attack")

	buffer["dash_pressed"] = Input.is_action_just_pressed("ui_dash")

# --- Public Methods ---

func setup(p_owner: Node, p_dependencies: Dictionary = {}) -> void:
	self.owner_node = p_owner as CharacterBody2D

	self.p_data = p_dependencies.get("data_resource")
	self.state_machine = p_dependencies.get("state_machine")
	self._config = p_dependencies.get("config")

	if not p_data or not state_machine or not _config:
		push_error("InputComponent.setup: Missing one or more required dependencies.")
		return

func teardown() -> void:
	owner_node = null
	p_data = null
	state_machine = null
	_config = null
	buffer.clear()