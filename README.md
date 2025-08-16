# BOX BATTLE

```
██████╗  ██████╗ ██╗  ██╗    ██████╗  █████╗ ████████╗████████╗██╗     ███████╗
██╔══██╗██╔═══██╗╗██╗██╔╝    ██╔══██╗██╔══██╗╚══██╔══╝╚══██╔══╝██║     ██╔════╝
██████╔╝██║   ██║╚███╔╝      ██████╔╝███████║   ██║      ██║   ██║     █████╗  
██╔══██╗██║   ██║██╔██╗      ██╔══██╗██╔══██║   ██║      ██║   ██║     ██╔══╝  
██████╔╝╚██████╔╝██╔╝ ██╗    ██████╔╝██║  ██║   ██║      ██║   ███████╗███████╗
╚═════╝  ╚═════╝ ╚═╝  ╚═╝    ╚═════╝ ╚═╝  ╚═╝   ╚═╝      ╚═╝   ╚══════╝╚══════╝
```


A combat-focused 2D action game built in Godot 4. This repo contains the engine, gameplay systems, and tools used to produce a modular, maintainable boss-arena prototype.

**Current Status:** Architecturally stable. The codebase has been fully refactored to use a modular, component-based entity system, a standardized code style, and data-driven design patterns.

---

## Architectural Highlights
- **Component-Based Entities:** The Player and Boss are lean orchestrators for single-responsibility components (`HealthComponent`, `PlayerPhysicsComponent`, `IComponent` interface).
- **State Pattern:** Complex entity logic is encapsulated in discrete state classes (`BaseState`, `BaseStateMachine`).
- **Data-Driven Design:** All gameplay tuning is managed in `Resource` files (`.tres`) for easy balancing.
- **Robust Core Systems:** A suite of decoupled singletons manage global services (`EventBus`, `SceneManager`, `ObjectPool`, `AudioManager`).
- **Performance:** Stutter is minimized via asynchronous level building, object pooling, and enhanced shader pre-warming.

---

## Quick Start
1.  Install Godot 4.x.
2.  Clone the repository.
3.  Open the project in Godot and run `res://src/scenes/main/main.tscn`.

**Controls (default)**
-   Move: Arrow Keys / WASD
-   Jump / Confirm: X / Space / Enter
-   Attack / Pogo: C / Left-Click
-   Dash: Z / Shift
-   Heal: Down + Jump (on ground)

---

## Repository Layout

src/
├── api/ # "Interface" contracts (IComponent, IDamageable)
├── core/ # Autoloaded singletons and core infrastructure
├── data/ # Data resources (.tres files for encounters, layouts)
├── entities/ # Player, Boss, Minions, and their components/states
├── scenes/ # Main scenes (game, loading, menus)
├── ui/ # UI components, HUD, and menu controllers
└── ...
docs/ # High-level design, architecture, and style guide


---

## Key Documentation
-   `docs/ARCHITECTURE.txt`: A high-level summary of all key technical patterns.
-   `docs/sprint_0_audit/STYLE-001_GDScript_Style_Guide.md`: The official coding standard for the project.
-   `docs/DESIGN.txt`: The design philosophy and breakdown of core gameplay mechanics.
-   `docs/CHANGELOG.txt`: A log of all notable changes to the project.