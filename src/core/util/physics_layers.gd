# src/core/util/physics_layers.gd
#
# An autoloaded singleton that provides named constants for the 2D physics
# layers defined in the project settings.
extends Node

const PLAYER = 1           # Layer 1
const WORLD = 2            # Layer 2
const ENEMY = 4            # Layer 3
const HAZARD = 8           # Layer 4
const ENEMY_PROJECTILE = 16  # Layer 5
const PLAYER_HITBOX = 32   # Layer 6
const PLAYER_HURTBOX = 64  # Layer 7