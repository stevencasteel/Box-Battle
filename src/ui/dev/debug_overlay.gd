# src/ui/dev/debug_overlay.gd
## A toggleable overlay for displaying real-time developer debug information.
extends CanvasLayer

# --- Node References ---
@onready var fps_label: Label = %FPSLabel
@onready var state_label: Label = %StateLabel
@onready var velocity_label: Label = %VelocityLabel
@onready var flags_label: Label = %FlagsLabel
@onready var state_history_label: Label = %StateHistoryLabel
@onready var input_buffer_label: Label = %InputBufferLabel
@onready var pools_label: Label = %PoolsLabel
@onready var fx_label: Label = %FXLabel
@onready var panel: Panel = %Panel

# --- Private Member Variables ---
var _target_entity: Node = null
var _services: ServiceLocator

# --- Godot Lifecycle Methods ---


func _ready() -> void:
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0, 0, 0, 0.6)
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Palette.COLOR_UI_ACCENT_PRIMARY
	panel.add_theme_stylebox_override("panel", panel_style)


func _process(_delta: float) -> void:
	var fps_text = "FPS: %d" % Engine.get_frames_per_second()
	fps_label.text = fps_text

	if not is_instance_valid(_target_entity) or not _target_entity.has_method("get_component"):
		state_label.text = "State: NO TARGET"
		velocity_label.text = "Velocity:"
		flags_label.text = "Flags:"
		state_history_label.text = "History:"
		input_buffer_label.text = "Input:"
	else:
		velocity_label.text = "Target: %s" % _target_entity.name

		var state_machine: BaseStateMachine = _target_entity.get_component(BaseStateMachine)
		var current_state_name = "N/A"
		if is_instance_valid(state_machine) and is_instance_valid(state_machine.current_state):
			current_state_name = state_machine.current_state.get_script().resource_path.get_file()
		state_label.text = "State: %s" % current_state_name

		var health_comp: HealthComponent = _target_entity.get_component(HealthComponent)
		var is_invincible_str = (
			str(health_comp.is_invincible()) if is_instance_valid(health_comp) else "N/A"
		)
		var on_floor_str = (
			str(_target_entity.is_on_floor()) if _target_entity is CharacterBody2D else "N/A"
		)

		var flags_text = "Flags: OnFloor(%s) Invincible(%s)" % [on_floor_str, is_invincible_str]
		if _target_entity is Player:
			flags_text += " CanDash(%s)" % _target_entity.entity_data.can_dash
			if is_instance_valid(state_machine):
				state_history_label.text = "History: " + ", ".join(state_machine.state_history)
			_update_player_input_buffer()
		else:
			state_history_label.text = "History:"
			input_buffer_label.text = "Input:"

		flags_label.text = flags_text

	if is_instance_valid(_services):
		var pool_stats: Dictionary = _services.object_pool.get_pool_stats()
		var pool_text_parts: Array[String] = []
		for pool_name in pool_stats:
			var stats = pool_stats[pool_name]
			pool_text_parts.append("%s [%d/%d]" % [pool_name, stats.active, stats.total])
		pools_label.text = "Pools:\n" + "\n".join(pool_text_parts)

		var fx_stats = _services.fx_manager.get_debug_stats()
		fx_label.text = "FX:\nShaders[%d] VFX[%d]" % [fx_stats.active_shaders, fx_stats.active_vfx]


# --- Public Methods ---
func set_target(entity: Node) -> void:
	_target_entity = entity

func inject_dependencies(p_services: ServiceLocator) -> void:
	_services = p_services


# --- Private Methods ---
func _update_player_input_buffer() -> void:
	var input_comp: InputComponent = _target_entity.get_component(InputComponent)
	if not is_instance_valid(input_comp):
		input_buffer_label.text = "Input: N/A"
		return

	var input_buffer: Dictionary = input_comp.buffer
	var input_text_parts: Array[String] = []
	for key in input_buffer:
		var value = input_buffer[key]
		var should_display = false
		if value is bool and value == true:
			should_display = true
		elif value is float and not is_zero_approx(value):
			should_display = true

		if should_display:
			input_text_parts.append("%s: %s" % [key, value])

	input_buffer_label.text = "Input: " + ", ".join(input_text_parts)
