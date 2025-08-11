# ADR-002: Communication Patterns (Signal vs. EventBus)

**Date:** 2025-08-10

**Status:** Adopted

---

## Context

The project utilizes two primary methods for communication between different parts of the codebase: Godot's built-in **Signal** system and our custom global **EventBus**. Without a clear standard, it can be ambiguous which tool to use, potentially leading to tightly-coupled systems that are difficult to maintain or debug.

This document defines the official standard for choosing a communication pattern.

## Decision

We will adhere to a clear "Local vs. Global" distinction for communication:

1. **Use Godot Signals for *Local* Communication.**
2. **Use the EventBus for *Global* Communication.**

---

### 1. Godot Signals: Local Communication

Signals are the preferred method for communication **within a single, self-contained scene** or between a parent node and its direct children. This represents a tightly-coupled, "owner-to-part" relationship.

**Use a Signal when:**
- A child node needs to tell its parent that something happened (e.g., a `Button` telling a `Menu` it was pressed).
- A parent node needs to broadcast a message to all of its direct children.
- A component needs to communicate its result back to its owner (e.g., `CombatComponent` emitting `pogo_bounce_requested` for `Player` to handle).

**Litmus Test:** If the sender and receiver are part of the same scene file (`.tscn`) and have a direct parent-child relationship, use a signal.

**Example (`player.gd`):**
```gdscript
# The HealthComponent (child) emits a signal.
signal died

# The Player (parent) listens to its own component.
health_component.died.connect(_on_health_component_died)
```

### 2. EventBus: Global Communication

The EventBus is the preferred method for communication **between disparate, decoupled systems**. The sender and receiver should have no direct knowledge of each other. This represents a loosely-coupled, "system-to-system" relationship.

**Use the EventBus when:**
- A gameplay event needs to be reflected in the UI (e.g., the Player's health changes, and the GameHUD must be updated).
- A UI action needs to trigger a global system change (e.g., a TitleScreen button opens a menu, and the GlobalHUD must show the mute icon).
- An entity in the game world needs to trigger an audio cue (e.g., the Boss dies, and the AudioManager needs to play a victory sound).

**Litmus Test:** If the sender and receiver are in completely different parts of the scene tree and do not know about each other's existence, use the EventBus.

**Example (player.gd emitting, game_hud.gd listening):**

```gdscript
# player.gd (Sender)
var ev = PlayerHealthChangedEvent.new()
EventBus.emit(EventCatalog.PLAYER_HEALTH_CHANGED, ev)

# game_hud.gd (Receiver)
EventBus.on(EventCatalog.PLAYER_HEALTH_CHANGED, on_player_health_changed)
```

## Consequences

**Positive:** This standard provides a clear, unambiguous rule that is easy to follow, promoting clean architecture and preventing "spaghetti" code where everything is globally connected via the EventBus. It keeps scenes self-contained and makes systems highly modular.

**Negative:** None. This is a best-practice clarification that reduces cognitive overhead.