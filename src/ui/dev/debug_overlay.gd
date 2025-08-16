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
@onready var object_pool_label: Label = %ObjectPoolLabel
@onready var panel: Panel = %Panel

# --- Private Member Variables ---
var _player_node: Player = null

# --- Godot Lifecycle Methods ---

func _ready() -> void:
	# --- Apply custom styling to the panel ---
	var panel_style = StyleBoxFlat.new()
	panel_style.bg_color = Color(0, 0, 0, 0.6) # Semi-transparent black
	panel_style.border_width_left = 2
	panel_style.border_width_top = 2
	panel_style.border_width_right = 2
	panel_style.border_width_bottom = 2
	panel_style.border_color = Palette.COLOR_UI_ACCENT_PRIMARY
	panel.add_theme_stylebox_override("panel", panel_style)
	
	# THE FIX: Ensure long text is clipped instead of overflowing the panel.
	state_history_label.clip_text = true
	input_buffer_label.clip_text = true
	object_pool_label.clip_text = true
	
	# Attempt to find the player node once the scene is ready.
	_player_node = get_tree().get_first_node_in_group(Identifiers.Groups.PLAYER) as Player

func _process(_delta: float) -> void:
	# --- General Info ---
	fps_label.text = "FPS: %d" % Engine.get_frames_per_second()

	# --- Player-Specific Info ---
	if not is_instance_valid(_player_node):
		state_label.text = "PLAYER NOT FOUND"
		velocity_label.text = ""
		flags_label.text = ""
		state_history_label.text = ""
		input_buffer_label.text = ""
		object_pool_label.text = ""
		return

	# --- State and Physics ---
	var state_machine: BaseStateMachine = _player_node.state_machine
	var current_state_name = "N/A"
	if is_instance_valid(state_machine) and is_instance_valid(state_machine.current_state):
		current_state_name = state_machine.current_state.get_script().resource_path.get_file()

	state_label.text = "State: %s" % current_state_name
	velocity_label.text = "Velocity: %s" % _player_node.velocity.round()

	var p_data: PlayerStateData = _player_node.p_data
	flags_label.text = "Flags: OnFloor(%s) CanDash(%s) Invincible(%s)" % [_player_node.is_on_floor(), p_data.can_dash, p_data.is_invincible]

	state_history_label.text = "History: " + ", ".join(state_machine.state_history)

	# --- Input Buffer ---
	var input_buffer: Dictionary = _player_node.input_component.buffer
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

	# --- Object Pool ---
	var pool_stats: Dictionary = ObjectPool.get_pool_stats()
	var pool_text_parts: Array[String] = []
	for pool_name in pool_stats:
		var stats = pool_stats[pool_name]
		pool_text_parts.append("%s [%d/%d]" % [pool_name, stats.active, stats.total])
	object_pool_label.text = "Pools: " + " ".join(pool_text_parts)
