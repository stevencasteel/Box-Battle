# Event Flow Map

**Date:** 2025-08-10
**Status:** Generated

---

This document maps all events defined in `EventCatalog.gd`. For each event, it lists all scripts that emit the event and all scripts that subscribe (listen) to it.

## Event: `PLAYER_HEALTH_CHANGED`

**Path:** `player.health_changed`

### Emitters (who sends this event?)
```
src/entities/player/player.gd:	EventBus.emit(EventCatalog.PLAYER_HEALTH_CHANGED, ev, self)
```

### Listeners (who listens for this event?)
```
src/ui/game_hud/game_hud.gd:	_player_health_token = EventBus.on(EventCatalog.PLAYER_HEALTH_CHANGED, on_player_health_changed)
```

---

## Event: `PLAYER_HEALING_CHARGES_CHANGED`

**Path:** `player.healing_charges_changed`

### Emitters (who sends this event?)
```
src/entities/player/player.gd:	EventBus.emit(EventCatalog.PLAYER_HEALING_CHARGES_CHANGED, ev, self)
```

### Listeners (who listens for this event?)
```
src/ui/game_hud/game_hud.gd:	_player_charges_token = EventBus.on(EventCatalog.PLAYER_HEALING_CHARGES_CHANGED, on_player_healing_charges_changed)
```

---

## Event: `PLAYER_TOOK_DAMAGE`

**Path:** `player.took_damage`

### Emitters (who sends this event?)
```
No emitters found.
```

### Listeners (who listens for this event?)
```
No listeners found.
```

---

## Event: `PLAYER_DIED`

**Path:** `player.died`

### Emitters (who sends this event?)
```
No emitters found.
```

### Listeners (who listens for this event?)
```
No listeners found.
```

---

## Event: `BOSS_HEALTH_CHANGED`

**Path:** `boss.health_changed`

### Emitters (who sends this event?)
```
src/entities/boss/base_boss.gd:	EventBus.emit(EventCatalog.BOSS_HEALTH_CHANGED, ev, self)
```

### Listeners (who listens for this event?)
```
src/ui/game_hud/game_hud.gd:	_boss_health_token = EventBus.on(EventCatalog.BOSS_HEALTH_CHANGED, on_boss_health_changed)
```

---

## Event: `BOSS_DIED`

**Path:** `boss.died`

### Emitters (who sends this event?)
```
No emitters found.
```

### Listeners (who listens for this event?)
```
No listeners found.
```

---

## Event: `GAME_PAUSED`

**Path:** `game.paused`

### Emitters (who sends this event?)
```
No emitters found.
```

### Listeners (who listens for this event?)
```
src/scenes/game/game.gd:	_pause_token = EventBus.on(EventCatalog.GAME_PAUSED, _on_game_paused)
```

---

## Event: `GAME_RESUMED`

**Path:** `game.resumed`

### Emitters (who sends this event?)
```
No emitters found.
```

### Listeners (who listens for this event?)
```
src/scenes/game/game.gd:	_resume_token = EventBus.on(EventCatalog.GAME_RESUMED, _on_game_resumed)
```

---

## Event: `MENU_OPENED`

**Path:** `ui.menu_opened`

### Emitters (who sends this event?)
```
src/ui/screens/controls_menu/controls_menu.gd:	EventBus.emit(EventCatalog.MENU_OPENED)
src/ui/screens/credits_menu/credits_menu.gd:	EventBus.emit(EventCatalog.MENU_OPENED)
src/ui/screens/options_menu/options_menu.gd:	EventBus.emit(EventCatalog.MENU_OPENED)
src/ui/screens/sound_menu/sound_menu.gd:	EventBus.emit(EventCatalog.MENU_OPENED)
src/ui/screens/title_screen/title_screen.gd:	EventBus.emit(EventCatalog.MENU_OPENED) # Announce that a menu is open
```

### Listeners (who listens for this event?)
```
src/ui/global_hud/global_hud.gd:	_menu_opened_token = EventBus.on(EventCatalog.MENU_OPENED, _on_menu_opened)
```

---

## Event: `MENU_CLOSED`

**Path:** `ui.menu_closed`

### Emitters (who sends this event?)
```
src/ui/screens/controls_menu/controls_menu.gd:	EventBus.emit(EventCatalog.MENU_CLOSED)
src/ui/screens/credits_menu/credits_menu.gd:	EventBus.emit(EventCatalog.MENU_CLOSED)
src/ui/screens/options_menu/options_menu.gd:	EventBus.emit(EventCatalog.MENU_CLOSED)
src/ui/screens/sound_menu/sound_menu.gd:	EventBus.emit(EventCatalog.MENU_CLOSED)
src/ui/screens/title_screen/title_screen.gd:	EventBus.emit(EventCatalog.MENU_CLOSED) # Announce that the menu is closing
```

### Listeners (who listens for this event?)
```
src/ui/global_hud/global_hud.gd:	_menu_closed_token = EventBus.on(EventCatalog.MENU_CLOSED, _on_menu_closed)
```

---

