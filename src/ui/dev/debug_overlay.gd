# src/ui/dev/debug_overlay.gd
# A simple, toggleable overlay for displaying real-time debug information.
extends CanvasLayer

@onready var label: Label = $Label

var player_node: Node = null

func _ready():
	# Attempt to find the player node once the scene is ready.
	player_node = get_tree().get_first_node_in_group(Identifiers.Groups.PLAYER)

func _process(_delta):
	# If the player node doesn't exist (e.g., in the main menu), do nothing.
	if not is_instance_valid(player_node):
		label.text = "PLAYER NOT FOUND"
		return

	# If the player exists, build the debug string.
	var state_machine = player_node.get_node_or_null("StateMachine")
	var current_state_name = "N/A"
	if is_instance_valid(state_machine) and is_instance_valid(state_machine.current_state):
		# Get the name of the state script file for a clear, readable name.
		current_state_name = state_machine.current_state.get_script().resource_path.get_file()

	var debug_text = """
	State: %s
	Velocity: %s
	""" % [current_state_name, player_node.velocity.round()]

	label.text = debug_text
