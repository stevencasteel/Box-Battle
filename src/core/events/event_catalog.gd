# src/core/events/event_catalog.gd
# This script serves as the canonical, central list of all event names in the project.
# By using these constants instead of raw strings, we gain IDE autocompletion and
# prevent typos that would lead to silent runtime failures.
extends Object
class_name EventCatalog

# --- Player Events ---
const PLAYER_HEALTH_CHANGED = "player.health_changed"
const PLAYER_HEALING_CHARGES_CHANGED = "player.healing_charges_changed"

# --- Boss / Entity Events ---
const BOSS_HEALTH_CHANGED = "boss.health_changed"

# --- UI State Events ---
const MENU_OPENED = "ui.menu_opened"
const MENU_CLOSED = "ui.menu_closed"