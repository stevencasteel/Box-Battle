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
	const MINION_SHOTS = &"minion_shots"
	const HOMING_BOSS_SHOTS = &"homing_boss_shots"
	const HIT_SPARKS = &"hit_sparks"


## Container for all Player state keys.
class PlayerStates:
	const MOVE = &"move"
	const JUMP = &"jump"
	const FALL = &"fall"
	const DASH = &"dash"
	const WALL_SLIDE = &"wall_slide"
	const ATTACK = &"attack"
	const HURT = &"hurt"
	const HEAL = &"heal"
	const POGO = &"pogo"


## Container for all Boss state keys.
class BossStates:
	const IDLE = &"idle"
	const ATTACK = &"attack"
	const COOLDOWN = &"cooldown"
	const PATROL = &"patrol"
	const LUNGE = &"lunge"
	const FALL = &"fall"


## Container for all Minion state keys.
class MinionStates:
	const IDLE = &"idle"
	const ATTACK = &"attack"
	const FALL = &"fall"