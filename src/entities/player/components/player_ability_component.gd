# src/entities/player/components/player_ability_component.gd
@tool
## Governs the activation logic for player abilities.
##
## Reads the input buffer and game state to determine if an action (like
## dashing or healing) can be performed, then instructs the StateMachine.
class_name PlayerAbilityComponent
extends IComponent

# --- Member Variables ---
var owner_node: Player
var p_data: PlayerStateData
var state_machine: BaseStateMachine
var input_component: InputComponent

# --- Godot Lifecycle Methods ---

func _physics_process(_delta: float) -> void:
	var current_state_key = state_machine.states.find_key(state_machine.current_state)
	if not current_state_key in owner_node.ACTION_ALLOWED_STATES:
		return

	# --- Attack / Charge Shot Logic ---
	if input_component.buffer.get("attack_just_pressed") and p_data.attack_cooldown_timer <= 0:
		p_data.is_charging = true
		p_data.charge_timer = 0.0

	if input_component.buffer.get("attack_released"):
		if p_data.is_charging:
			if p_data.charge_timer >= p_data.config.player_charge_time:
				owner_node.combat_component.fire_shot()
			else:
				state_machine.change_state(owner_node.State.ATTACK)
			p_data.is_charging = false

	# --- Dash Logic ---
	if input_component.buffer.get("dash_pressed") and p_data.can_dash and p_data.dash_cooldown_timer <= 0:
		state_machine.change_state(owner_node.State.DASH)

	# --- Heal Logic ---
	var can_try_heal = owner_node.is_on_floor() and \
		input_component.buffer.get("down") and \
		input_component.buffer.get("jump_pressed") and \
		p_data.healing_charges > 0 and \
		is_zero_approx(owner_node.velocity.x)
	
	if can_try_heal:
		state_machine.change_state(owner_node.State.HEAL)

# --- Public Methods ---

func setup(p_owner: Node, p_dependencies: Dictionary = {}) -> void:
	self.owner_node = p_owner as Player
	self.p_data = p_dependencies.get("data_resource")
	self.state_machine = p_dependencies.get("state_machine")
	self.input_component = p_dependencies.get("input_component")

func teardown() -> void:
	owner_node = null
	p_data = null
	state_machine = null
	input_component = null