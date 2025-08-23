# res://src/projectiles/player_shot.gd
class_name PlayerShot
extends "res://src/projectiles/base_projectile.gd"

# Per-projectile tuneable default (Inspector-friendly).
@export var default_speed: float = 1000.0

func _ready() -> void:
	# Visual only; movement & collision handled by BaseProjectile.
	if is_instance_valid(visual):
		visual.color = Palette.COLOR_PLAYER_PROJECTILE


# Ensure the speed is set every time this instance is (re)activated by the pool.
func activate(p_dependencies: Dictionary = {}) -> void:
	# First let the base class do its activation (set process, collision, pool ref, etc.)
	super.activate(p_dependencies)
	# Then apply player-shot-specific runtime defaults so they apply on reuse.
	speed = default_speed


func _on_area_entered(area: Area2D) -> void:
	if not _is_active:
		return
	# Player shots can destroy enemy projectiles on contact.
	if area.is_in_group(Identifiers.Groups.ENEMY_PROJECTILE):
		if is_instance_valid(_object_pool):
			_object_pool.return_instance.call_deferred(area)

	# Then proceed with the base collision handling (damage + returning this shot to the pool).
	super._on_area_entered(area)
