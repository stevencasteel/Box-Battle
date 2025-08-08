# src/core/event_catalog.gd
# This script serves as the canonical, central list of all event names in the project.
# By using these constants instead of raw strings, we gain IDE autocompletion and
# prevent typos that would lead to silent runtime failures.
extends Object
class_name EventCatalog

# --- Player Events ---
const PLAYER_HEALTH_CHANGED = "player.health_changed"
const PLAYER_HEALING_CHARGES_CHANGED = "player.healing_charges_changed"
const PLAYER_TOOK_DAMAGE = "player.took_damage"
const PLAYER_DIED = "player.died"

# --- Boss / Entity Events ---
const BOSS_HEALTH_CHANGED = "boss.health_changed"
const BOSS_DIED = "boss.died"

# --- Game State Events ---
const GAME_PAUSED = "game.paused"
const GAME_RESUMED = "game.resumed"