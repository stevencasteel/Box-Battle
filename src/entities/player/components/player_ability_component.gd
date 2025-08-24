# src/entities/player/components/player_ability_component.gd
@tool
## Governs the activation logic for player abilities.
##
## Reads the input buffer and game state to determine if an action (like
## dashing or healing) can be performed, then instructs the StateMachine.
class_name PlayerAbilityComponent
extends IComponent

# --- Constants ---
const JumpHelper = preload("res://src/entities/player/components/player_jump_helper.gd")

# --- Member Variables ---
var owner_node: Player
var p_data: PlayerStateData

# --- Godot Lifecycle Methods ---


func _physics_process(_delta: float) -> void:
	if not is_instance_valid(owner_node):
		return

	var state_machine: BaseStateMachine = owner_node.get_component(BaseStateMachine)
	var input_component: InputComponent = owner_node.get_component(InputComponent)
	if not is_instance_valid(state_machine) or not is_instance_valid(input_component):
		return

	var current_state_key = state_machine._current_state_key

	if not current_state_key in Player.ACTION_ALLOWED_STATES:
		return

	# --- Action Checks (Prioritized) ---

	if input_component.buffer.get("jump_just_pressed"):
		var is_holding_down = input_component.buffer.get("down", false)

		# 1. Heal (Highest priority for this input combination)
		if (
			is_holding_down
			and p_data.healing_charges > 0
			and owner_node.is_on_floor()
			and is_zero_approx(owner_node.velocity.x)
		):
			state_machine.change_state(Identifiers.PlayerStates.HEAL)
			return # Stop further processing of this input

		# 2. Platform Drop
		if is_holding_down:
			if JumpHelper.try_platform_drop(owner):
				return # Stop further processing

		# 3. Standard Jump
		if JumpHelper.try_jump(owner, p_data):
			return # Stop further processing

	if input_component.buffer.get("attack_just_pressed") and p_data.attack_cooldown_timer <= 0:
		p_data.is_charging = true
		p_data.charge_timer = 0.0

	if input_component.buffer.get("attack_released"):
		if p_data.is_charging:
			if p_data.charge_timer >= p_data.config.player_charge_time:
				owner_node.get_component(CombatComponent).fire_shot()
			elif input_component.buffer.get("down"):
				state_machine.change_state(Identifiers.PlayerStates.POGO)
			else:
				state_machine.change_state(Identifiers.PlayerStates.ATTACK)
			p_data.is_charging = false

	if (
		input_component.buffer.get("dash_pressed")
		and p_data.can_dash
		and p_data.dash_cooldown_timer <= 0
	):
		state_machine.change_state(Identifiers.PlayerStates.DASH)


# --- Public Methods ---


func setup(p_owner: Node, p_dependencies: Dictionary = {}) -> void:
	self.owner_node = p_owner as Player
	self.p_data = p_dependencies.get("data_resource")


func teardown() -> void:
	set_physics_process(false)
	owner_node = null
	p_data = null