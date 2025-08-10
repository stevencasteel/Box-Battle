# src/entities/components/input_component.gd
#
# A component that centralizes all input polling and processing for the player.
class_name InputComponent
extends ComponentInterface

var owner_node: CharacterBody2D
var p_data: PlayerStateData
var combat_component: CombatComponent

# CORRECTED: Renamed `owner` to `p_owner` and added underscores to unused parameters.
func setup(p_owner: Node, _config: Resource = null, _services = null, p_combat_component: CombatComponent = null) -> void:
	self.owner_node = p_owner as CharacterBody2D
	self.p_data = owner_node.p_data
	self.combat_component = p_combat_component
	
	if not combat_component:
		push_error("InputComponent requires a valid CombatComponent to be provided.")

func teardown() -> void:
	owner_node = null
	p_data = null
	combat_component = null

func process_physics():
	if Input.is_action_just_pressed("ui_jump"):
		p_data.jump_buffer_timer = CombatDB.config.player_jump_buffer
	
	if not owner_node.states.find_key(owner_node.current_state) in owner_node.ACTION_ALLOWED_STATES:
		return
	
	if Input.is_action_just_pressed("ui_attack") and p_data.attack_cooldown_timer <= 0:
		p_data.is_charging = true
		p_data.charge_timer = 0.0
	
	if Input.is_action_just_released("ui_attack"):
		if p_data.is_charging:
			if p_data.charge_timer >= CombatDB.config.player_charge_time:
				combat_component.fire_shot()
			else:
				owner_node.change_state(owner_node.State.ATTACK)
			p_data.is_charging = false
	
	if Input.is_action_just_pressed("ui_dash") and p_data.can_dash and p_data.dash_cooldown_timer <= 0:
		owner_node.change_state(owner_node.State.DASH)
	
	if owner_node.is_on_floor() and Input.is_action_pressed("ui_down") and Input.is_action_pressed("ui_jump") and p_data.healing_charges > 0 and is_zero_approx(owner_node.velocity.x):
		owner_node.change_state(owner_node.State.HEAL)

func process_unhandled_input(event: InputEvent):
	if is_instance_valid(owner_node) and is_instance_valid(owner_node.current_state):
		owner_node.current_state.process_input(event)
