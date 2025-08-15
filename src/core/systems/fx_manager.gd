# src/core/systems/fx_manager.gd
# A new singleton to handle purely aesthetic "game feel" effects,
# like hit-stop and screen shake. This keeps the core gameplay logic
# clean and focused on rules.
extends Node

var _is_hit_stop_active = false

# --- Public API ---

func request_hit_stop(duration: float):
	# Prevent multiple hit-stops from overlapping, which can feel strange.
	if _is_hit_stop_active:
		return
	
	_is_hit_stop_active = true
	get_tree().paused = true
	
	await get_tree().create_timer(duration, true, false, true).timeout
	
	# Check if the tree is still paused. It might have been unpaused
	# by the actual game pause menu, in which case we don't want to
	# interfere.
	if get_tree().paused:
		get_tree().paused = false
		
	_is_hit_stop_active = false
