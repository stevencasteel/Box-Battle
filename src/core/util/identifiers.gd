# src/core/util/identifiers.gd
# A central authority for all string-based identifiers used in the project,
# such as group names and pool keys. Using these constants prevents bugs
# caused by typos in raw strings.
extends Node

# Usage: Identifiers.Groups.PLAYER
class Groups:
	const PLAYER = "player"
	const ENEMY = "enemy"
	const WORLD = "world"
	const HAZARD = "hazard"
	const ONEWAY_PLATFORMS = "oneway_platforms"
	const PLAYER_PROJECTILE = "player_projectile"
	const ENEMY_PROJECTILE = "enemy_projectile"

# Usage: Identifiers.Pools.PLAYER_SHOTS
class Pools:
	const PLAYER_SHOTS = &"player_shots"
	const BOSS_SHOTS = &"boss_shots"
	const TURRET_SHOTS = &"turret_shots"

# This script is intentionally minimal and has no _ready() function.