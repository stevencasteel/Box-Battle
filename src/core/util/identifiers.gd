# src/core/util/identifiers.gd
## An autoloaded singleton that provides a central authority for all string-based
## identifiers used in the project, such as group names and pool keys.
##
## Using these constants prevents bugs caused by typos in raw strings.
extends Node

## A container for all physics group names.
## Usage: Identifiers.Groups.PLAYER
class Groups:
	const PLAYER = "player"
	const ENEMY = "enemy"
	const WORLD = "world"
	const HAZARD = "hazard"
	const ONEWAY_PLATFORMS = "oneway_platforms"
	const PLAYER_PROJECTILE = "player_projectile"
	const ENEMY_PROJECTILE = "enemy_projectile"

## A container for all ObjectPool keys.
## Usage: Identifiers.Pools.PLAYER_SHOTS
class Pools:
	const PLAYER_SHOTS = &"player_shots"
	const BOSS_SHOTS = &"boss_shots"
	const TURRET_SHOTS = &"turret_shots"
	const HIT_SPARKS = &"hit_sparks"