# src/core/physics_layers.gd
#
# An autoloaded singleton that provides named constants for the 2D physics
# layers defined in the project settings. This prevents the use of "magic
# numbers" for collision layers and masks, making the code more readable
# and easier to maintain.
extends Node

# The bitmask value for each layer (2^n).
const PLAYER = 1
const WORLD = 2
const ENEMY = 4
const HAZARD = 8
const ENEMY_PROJECTILE = 16
const PLAYER_HITBOX = 32
const PLAYER_HURTBOX = 64