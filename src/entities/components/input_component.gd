# src/entities/components/input_component.gd
#
# A component that centralizes all input polling and processing for the player.
class_name InputComponent
extends ComponentInterface

var owner_node: CharacterBody2D
var p_data: PlayerStateData
var combat_component: CombatComponent
var state_machine: BaseStateMachine

func setup(p_owner: Node, p_dependencies: Dictionary = {}) -> void:
	self.owner_node = p_owner as CharacterBody2D
	self.p_data = p_dependencies.get("data_resource")
	self.state_machine = p_dependencies.get("state_machine")
	self.combat_component = p_dependencies.get("combat_component")
	
	if not p_data or not state_machine or not combat_component:
		push_error("InputComponent.setup: Missing required dependencies.")
		return

func teardown() -> void:
	owner_node = null
	p_data = null
	combat_component = null
	state_machine = null

# CORRECTED: Renamed to `_physics_process` to match Godot's engine callback.
func _physics_process(_delta):
	if Input.is_action_just_pressed("ui_jump"):
		p_data.jump_buffer_timer = CombatDB.config.player_jump_buffer
	
	if not state_machine.states.find_key(state_machine.current_state) in owner_node.ACTION_ALLOWED_STATES:
		return
	
	if Input.is_action_just_pressed("ui_attack") and p_data.attack_cooldown_timer <= 0:
		p_data.is_charging = true
		p_data.charge_timer = 0.0
	
	if Input.is_action_just_released("ui_attack"):
		if p_data.is_charging:
			if p_data.charge_timer >= CombatDB.config.player_charge_time:
				combat_component.fire_shot()
			else:
				state_machine.change_state(owner_node.State.ATTACK)
			p_data.is_charging = false
	
	if Input.is_action_just_pressed("ui_dash") and p_data.can_dash and p_data.dash_cooldown_timer <= 0:
		state_machine.change_state(owner_node.State.DASH)
	
	if owner_node.is_on_floor() and Input.is_action_pressed("ui_down") and Input.is_action_pressed("ui_jump") and p_data.healing_charges > 0 and is_zero_approx(owner_node.velocity.x):
		state_machine.change_state(owner_node.State.HEAL)

# CORRECTED: Renamed to `_unhandled_input` to match Godot's engine callback.
func _unhandled_input(event: InputEvent):
	if is_instance_valid(state_machine) and is_instance_valid(state_machine.current_state):
		state_machine.current_state.process_input(event)
