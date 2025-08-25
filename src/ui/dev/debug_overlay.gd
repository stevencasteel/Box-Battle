# src/ui/dev/debug_overlay.gd
## A toggleable overlay for displaying real-time developer debug information.
extends CanvasLayer

# --- Node References ---
@onready var entity_panel: PanelContainer = %EntityPanel
@onready var global_panel: PanelContainer = %GlobalPanel
@onready var target_label: Label = %TargetLabel
@onready var position_label: Label = %PositionLabel
@onready var velocity_label: Label = %VelocityLabel
@onready var health_label: Label = %HealthLabel
@onready var state_label: Label = %StateLabel
@onready var flags_label: Label = %FlagsLabel
@onready var timers_label: Label = %TimersLabel
@onready var input_buffer_label: Label = %InputBufferLabel
@onready var state_history_label: Label = %StateHistoryLabel
@onready var fps_label: Label = %FPSLabel
@onready var fx_label: Label = %FXLabel
@onready var pools_vbox: VBoxContainer = %PoolsVBox
@onready var toggle_collision_button: Button = %ToggleCollisionButton
@onready var pause_button: Button = %PauseButton
@onready var toggle_invincibility_button: Button = %ToggleInvincibilityButton

# --- Private Member Variables ---
var _target_entity: Node = null
var _services: ServiceLocator
var _pool_labels: Dictionary = {}
var _invincibility_debug_token: int = 0

# --- Godot Lifecycle Methods ---


func _ready() -> void:
	# This node must always process so it can handle unpausing the game.
	process_mode = Node.PROCESS_MODE_ALWAYS
	
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0.1, 0.1, 0.1, 0.8)
	panel_style.border_width_left = 1
	panel_style.border_width_top = 1
	panel_style.border_width_right = 1
	panel_style.border_width_bottom = 1
	panel_style.border_color = Palette.COLOR_UI_ACCENT_PRIMARY
	entity_panel.add_theme_stylebox_override("panel", panel_style)
	global_panel.add_theme_stylebox_override("panel", panel_style)


func _process(_delta: float) -> void:
	_update_global_info()
	_update_entity_info()


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug_toggle_collision"):
		toggle_collision_button.button_pressed = not toggle_collision_button.button_pressed
	
	if event.is_action_pressed("debug_toggle_invincibility"):
		toggle_invincibility_button.button_pressed = not toggle_invincibility_button.button_pressed

	if event.is_action_pressed("debug_pause_game"):
		pause_button.button_pressed = not pause_button.button_pressed


# --- Public Methods ---
func set_target(entity: Node) -> void:
	_target_entity = entity


func inject_dependencies(p_services: ServiceLocator) -> void:
	_services = p_services


# --- Private Update Methods ---
func _update_global_info() -> void:
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

	if is_instance_valid(_services):
		var fx_stats = _services.fx_manager.get_debug_stats()
		fx_label.text = "FX: Shaders[%d] VFX[%d]" % [fx_stats.active_shaders, fx_stats.active_vfx]

		var pool_stats: Dictionary = _services.object_pool.get_pool_stats()
		for pool_name in pool_stats:
			if not _pool_labels.has(pool_name):
				var new_label = Label.new()
				new_label.add_theme_font_override("font", load("res://addons/gut/fonts/AnonymousPro-Regular.ttf"))
				new_label.add_theme_font_size_override("font_size", 20)
				pools_vbox.add_child(new_label)
				_pool_labels[pool_name] = new_label
			
			var stats = pool_stats[pool_name]
			_pool_labels[pool_name].text = "- %s [%d/%d]" % [pool_name, stats.active, stats.total]


func _update_entity_info() -> void:
	if not is_instance_valid(_target_entity) or not _target_entity.has_method("get_component"):
		target_label.text = "Target: NONE"
		position_label.text = "Position:"
		velocity_label.text = "Velocity:"
		health_label.text = "Health:"
		state_label.text = "State:"
		flags_label.text = "Flags:"
		timers_label.text = "Timers:"
		input_buffer_label.text = "Input:"
		state_history_label.text = "History:"
		return

	target_label.text = "Target: %s (%s)" % [_target_entity.name, _target_entity.get_class()]
	position_label.text = "Position: %s" % _target_entity.global_position.round()
	velocity_label.text = "Velocity: %s" % _target_entity.velocity.round()

	var state_machine: BaseStateMachine = _target_entity.get_component(BaseStateMachine)
	var current_state_name = "N/A"
	if is_instance_valid(state_machine) and is_instance_valid(state_machine.current_state):
		current_state_name = state_machine.current_state.get_script().resource_path.get_file().trim_suffix(".gd")
	state_label.text = "State: %s" % current_state_name
	
	var health_comp: HealthComponent = _target_entity.get_component(HealthComponent)
	if is_instance_valid(health_comp):
		health_label.text = "Health: %d / %d" % [health_comp.entity_data.health, health_comp.entity_data.max_health]
		var is_invincible_str = str(health_comp.is_invincible())
		flags_label.text = "Flags: OnFloor(%s) Invincible(%s)" % [str(_target_entity.is_on_floor()), is_invincible_str]
	
	if is_instance_valid(state_machine):
		state_history_label.text = "History: %s" % ", ".join(state_machine.state_history)

	if _target_entity is Player:
		_update_player_specific_info()
	else:
		timers_label.text = "Timers:"
		input_buffer_label.text = "Input:"


func _update_player_specific_info() -> void:
	var p_data = _target_entity.entity_data
	var timers_text = "Timers: DashCD[%.2f] AtkCD[%.2f]" % [p_data.dash_cooldown_timer, p_data.attack_cooldown_timer]
	timers_label.text = timers_text
	
	var input_comp: InputComponent = _target_entity.get_component(InputComponent)
	if is_instance_valid(input_comp):
		var input_buffer: Dictionary = input_comp.buffer
		var input_text_parts: Array[String] = []
		for key in input_buffer:
			var value = input_buffer[key]
			if (value is bool and value) or (value is float and not is_zero_approx(value)):
				input_text_parts.append("%s:%s" % [key, str(value).pad_decimals(2)])
		input_buffer_label.text = "Input: %s" % ", ".join(input_text_parts)


# --- Signal Handlers ---
func _on_toggle_collision_toggled(button_pressed: bool) -> void:
	get_tree().debug_collisions_hint = button_pressed


func _on_toggle_invincibility_toggled(button_pressed: bool) -> void:
	var player: Player = get_tree().get_first_node_in_group(Identifiers.Groups.PLAYER) as Player
	if not is_instance_valid(player):
		return

	var health_comp: HealthComponent = player.get_component(HealthComponent)
	if not is_instance_valid(health_comp):
		return

	if button_pressed:
		if _invincibility_debug_token == 0:
			_invincibility_debug_token = health_comp.grant_invincibility(self)
	else:
		if _invincibility_debug_token != 0:
			health_comp.release_invincibility(_invincibility_debug_token)
			_invincibility_debug_token = 0


func _on_pause_toggled(button_pressed: bool) -> void:
	get_tree().paused = button_pressed
