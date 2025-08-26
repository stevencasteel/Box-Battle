# src/entities/minions/movement_logic/flying_patrol_movement_logic.gd
@tool
## A concrete movement strategy for an entity that moves vertically between
## two explicit waypoints, ignoring gravity.
class_name FlyingPatrolMovementLogic
extends MovementLogic

@export var patrol_speed: float = 150.0

# Store the patrol points on a per-instance basis to support multiple minions.
var _patrol_points: Dictionary = {}


func execute(delta: float, minion: Minion, _state_data: MinionStateData) -> Vector2:
	var instance_id = minion.get_instance_id()
	
	# Initialize patrol points on the first run for this specific minion instance.
	if not _patrol_points.has(instance_id):
		# Define patrol points using our clear Grid Coordinate system.
		# The upper waypoint for this minion.
		var top_patrol_grid_pos = Vector2i(16, 10)
		
		# Convert grid coordinates to world-space coordinates for the target.
		var top_point = GridUtils.grid_to_world(top_patrol_grid_pos)
		# The minion's "home" position is its spawn point.
		var bottom_point = minion.global_position
		
		_patrol_points[instance_id] = {
			"top": top_point,
			"bottom": bottom_point,
			"target": top_point
		}
	
	var patrol_data = _patrol_points[instance_id]
	var target_position = patrol_data.target
	
	# This is a kinematic movement. We directly manipulate the position.
	minion.global_position = minion.global_position.move_toward(target_position, patrol_speed * delta)
	
	# If the target is reached, switch to the other point.
	if minion.global_position.distance_to(target_position) < 1.0:
		if target_position == patrol_data.top:
			patrol_data.target = patrol_data.bottom
		else:
			patrol_data.target = patrol_data.top
	
	# Return Vector2.ZERO because the base minion's move_and_slide() is not needed.
	return Vector2.ZERO
