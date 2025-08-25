# src/entities/player/components/player_ability_component.gd
@tool
## Governs the activation logic for player abilities.
##
## Reads the input buffer and game state to determine if an action (like
## dashing or healing) can be performed, then directly commands the state machine.
class_name PlayerAbilityComponent
extends IComponent

# --- Constants ---
const JumpHelper = preload("res://src/entities/player/components/player_jump_helper.gd")

# --- Member Variables ---
var owner_node: Player
var p_data: PlayerStateData
var _state_machine: BaseStateMachine # Direct reference to the FSM

# --- Godot Lifecycle Methods ---
func _ready() -> void:
	process_priority = 0


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(owner_node) or not is_instance_valid(_state_machine):
		return

	var input_component: InputComponent = owner_node.get_component(InputComponent)
	if not is_instance_valid(input_component):
		return

	var current_state_key = _state_machine._current_state_key

	if not current_state_key in Player.ACTION_ALLOWED_STATES:
		return

	# --- Action Checks (Prioritized) ---
	if input_component.buffer.get("jump_just_pressed"):
		var is_holding_down = input_component.buffer.get("down", false)

		if (
			is_holding_down
			and p_data.healing_charges > 0
			and owner_node.is_on_floor()
			and is_zero_approx(owner_node.velocity.x)
		):
			_state_machine.change_state(Identifiers.PlayerStates.HEAL, {})
			return

		if is_holding_down:
			if JumpHelper.try_platform_drop(owner_node):
				return

		if JumpHelper.try_jump(owner_node, p_data):
			return

	if input_component.buffer.get("attack_just_pressed") and p_data.attack_cooldown_timer <= 0:
		p_data.is_charging = true
		p_data.charge_timer = 0.0

	if input_component.buffer.get("attack_released"):
		if p_data.is_charging:
			if p_data.charge_timer >= p_data.config.player_charge_time:
				owner_node.get_component(CombatComponent).fire_shot()
			elif input_component.buffer.get("down"):
				_state_machine.change_state(Identifiers.PlayerStates.POGO, {})
			else:
				_state_machine.change_state(Identifiers.PlayerStates.ATTACK, {})
			p_data.is_charging = false

	if (
		input_component.buffer.get("dash_pressed")
		and p_data.can_dash
		and p_data.dash_cooldown_timer <= 0
	):
		_state_machine.change_state(Identifiers.PlayerStates.DASH, {})


# --- Public Methods ---
func setup(p_owner: Node, p_dependencies: Dictionary = {}) -> void:
	self.owner_node = p_owner as Player
	self.p_data = p_dependencies.get("data_resource")
	# Get a direct, permanent reference to the state machine.
	self._state_machine = owner_node.get_component(BaseStateMachine)
	assert(is_instance_valid(_state_machine), "PlayerAbilityComponent could not find the StateMachine.")


func teardown() -> void:
	set_physics_process(false)
	owner_node = null
	p_data = null
	_state_machine = null
