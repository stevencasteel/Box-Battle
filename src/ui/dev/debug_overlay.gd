# src/ui/dev/debug_overlay.gd
## A simple, toggleable overlay for displaying real-time debug information.
extends CanvasLayer

# --- Node References ---
@onready var label: Label = $Label

# --- Private Member Variables ---
var _player_node: Node = null

# --- Godot Lifecycle Methods ---

func _ready() -> void:
	# Attempt to find the player node once the scene is ready.
	_player_node = get_tree().get_first_node_in_group(Identifiers.Groups.PLAYER)

func _process(_delta: float) -> void:
	if not is_instance_valid(_player_node):
		label.text = "PLAYER NOT FOUND"
		return

	# Build the debug string with real-time player data.
	var state_machine: BaseStateMachine = _player_node.get_node_or_null("StateMachine")
	var current_state_name = "N/A"
	if is_instance_valid(state_machine) and is_instance_valid(state_machine.current_state):
		current_state_name = state_machine.current_state.get_script().resource_path.get_file()

	var debug_text = """
	State: %s
	Velocity: %s
	""" % [current_state_name, _player_node.velocity.round()]

	label.text = debug_text