# src/core/events/event_catalog.gd
## A central, canonical list of all event names in the project.
##
## By using these constants instead of raw strings (e.g., [code]EventBus.emit(EventCatalog.PLAYER_DIED)[/code]),
## we gain IDE autocompletion and prevent typos that lead to silent runtime failures.
class_name EventCatalog
extends Object

# --- Player Events ---
const PLAYER_HEALTH_CHANGED = "player.health_changed"
const PLAYER_HEALING_CHARGES_CHANGED = "player.healing_charges_changed"

# --- Boss / Entity Events ---
const BOSS_HEALTH_CHANGED = "boss.health_changed"
const BOSS_DIED = "boss.died"
const BOSS_PHASE_CHANGED = "boss.phase_changed"

# --- Game State Events ---
const SCENE_TRANSITION_STARTED = "scene.transition_started"

# --- UI State Events ---
const MENU_OPENED = "ui.menu_opened"
const MENU_CLOSED = "ui.menu_closed"
