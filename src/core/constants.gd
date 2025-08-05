# src/core/constants.gd
#
# This singleton holds global game design constants. Centralizing these values
# makes it much easier to balance and tune the game's feel without having to
# hunt through multiple files.
extends Node

# --- Audio ---
const NUM_SFX_PLAYERS = 8 # The number of sound effects that can play at once.

# --- Arena Design ---
const TILE_SIZE = 50

# --- General Physics ---
const GRAVITY = 1200.0

# --- Player Physics ---
const PLAYER_SPEED = 450.0
const PLAYER_JUMP_FORCE = 680.0
const POGO_FORCE = 450.0
const COYOTE_TIME = 0.1
const JUMP_BUFFER = 0.1
const JUMP_RELEASE_DAMPENER = 0.4
const WALL_COYOTE_TIME = 0.05
# Set to 0 to disable double jump for testing. Set back to 1 to re-enable.
const MAX_AIR_JUMPS = 0
const DASH_SPEED = 1400.0
const DASH_DURATION = 0.15
const DASH_COOLDOWN = 0.5
const WALL_SLIDE_SPEED = 120.0
const WALL_JUMP_FORCE_X = 1650.0
const WALL_JUMP_FORCE_Y = 680.0

# --- Player Combat & Health ---
const PLAYER_MAX_HEALTH = 5
const PLAYER_HEAL_DURATION = 2.0 # How many seconds it takes to heal.
const PLAYER_MAX_HEALING_CHARGES = 1 # The maximum number of heal charges the player can store.
const ATTACK_COOLDOWN = 0.12
const CHARGE_TIME = 0.35
const ATTACK_DURATION = 0.1
const KNOCKBACK_SPEED = 700.0
const KNOCKBACK_DURATION = 0.1
const HAZARD_KNOCKBACK_SPEED = 400.0
const DETERMINATION_PER_CHARGE = 10
const PLAYER_INVINCIBILITY_DURATION = 1.5

# --- Boss Stats ---
const BOSS_HEALTH = 30