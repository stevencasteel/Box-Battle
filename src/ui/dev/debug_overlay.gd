# src/ui/dev/debug_overlay.gd
## A toggleable overlay for displaying real-time developer debug information.
class_name DebugOverlay
extends CanvasLayer

# --- Node References ---
@onready var state_label: Label = %StateLabel
@onready var velocity_label: Label = %VelocityLabel
@onready var flags_label: Label = %FlagsLabel
@onready var state_history_label: Label = %StateHistoryLabel
@onready var input_buffer_label: Label = %InputBufferLabel
@onready var object_pool_label: Label = %ObjectPoolLabel
@onready var panel: Panel = %Panel

# --- Private Member Variables ---
var _target_entity: Node = null

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
	
	state_history_label.clip_text = true
	input_buffer_label.clip_text = true
	object_pool_label.clip_text = true

func _process(_delta: float) -> void:
	var fps_text = "FPS: %d" % Engine.get_frames_per_second()
	
	if not is_instance_valid(_target_entity):
		state_label.text = "NO TARGET SELECTED"
		velocity_label.text = fps_text
		flags_label.text = ""
		state_history_label.text = ""
		input_buffer_label.text = ""
		object_pool_label.text = ""
		return

	velocity_label.text = "%s | %s" % [_target_entity.name, fps_text]

	var state_machine: BaseStateMachine = _target_entity.state_machine
	var current_state_name = "N/A"
	if is_instance_valid(state_machine) and is_instance_valid(state_machine.current_state):
		current_state_name = state_machine.current_state.get_script().resource_path.get_file()

	state_label.text = "State: %s" % current_state_name

	# --- Flags ---
	var health_comp: HealthComponent = _target_entity.health_component
	var is_invincible_str = str(health_comp.is_invincible()) if is_instance_valid(health_comp) else "N/A"
	var on_floor_str = str(_target_entity.is_on_floor())
	
	var flags_text = "Flags: OnFloor(%s) Invincible(%s)" % [on_floor_str, is_invincible_str]
	# THE FIX: Add player-specific flags only when inspecting the player.
	if _target_entity is Player:
		flags_text += " CanDash(%s)" % _target_entity.entity_data.can_dash
		state_history_label.text = "History: " + ", ".join(state_machine.state_history)
		_update_player_input_buffer()
	else:
		state_history_label.text = ""
		input_buffer_label.text = ""

	flags_label.text = flags_text

	# --- Object Pool (global) ---
	var pool_stats: Dictionary = ObjectPool.get_pool_stats()
	var pool_text_parts: Array[String] = []
	for pool_name in pool_stats:
		var stats = pool_stats[pool_name]
		pool_text_parts.append("%s [%d/%d]" % [pool_name, stats.active, stats.total])
	object_pool_label.text = "Pools: " + " ".join(pool_text_parts)

# --- Public Methods ---
func set_target(entity: Node) -> void:
	_target_entity = entity

# --- Private Methods ---
func _update_player_input_buffer() -> void:
	var input_buffer: Dictionary = _target_entity.input_component.buffer
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
