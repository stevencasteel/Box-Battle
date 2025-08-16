# src/core/systems/fx_manager.gd
## An autoloaded singleton to handle purely aesthetic "game feel" effects.
##
## This separates feedback like hit-stop and screen shake from core gameplay
## logic, improving modularity and adhering to SRP.
extends Node

# --- Private Member Variables ---
var _is_hit_stop_active: bool = false

# --- Public Methods ---

## Pauses the entire game tree for a short duration to add impact to an event.
func request_hit_stop(duration: float) -> void:
	# Prevent multiple hit-stops from overlapping, which can feel jarring.
	if _is_hit_stop_active:
		return

	_is_hit_stop_active = true
	get_tree().paused = true

	await get_tree().create_timer(duration, true, false, true).timeout

	# Check if the tree is still paused by the actual game menu before unpausing.
	if get_tree().paused:
		get_tree().paused = false

	_is_hit_stop_active = false