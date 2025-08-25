
```
          ██████╗  ██████╗ ██╗  ██╗    ██████╗  █████╗ ████████╗████████╗██╗     ███████╗
          ██╔══██╗██╔═══██╗ ██╗██╔╝    ██╔══██╗██╔══██╗╚══██╔══╝╚══██╔══╝██║     ██╔════╝
          ██████╔╝██║   ██║  ███╔╝     ██████╔╝███████║   ██║      ██║   ██║     █████╗  
          ██╔══██╗██║   ██║ ██╔██╗     ██╔══██╗██╔══██║   ██║      ██║   ██║     ██╔══╝  
          ██████╔╝╚██████╔╝██╔╝ ██╗    ██████╔╝██║  ██║   ██║      ██║   ███████╗███████╗
          ╚═════╝  ╚═════╝ ╚═╝  ╚═╝    ╚═════╝ ╚═╝  ╚═╝   ╚═╝      ╚═╝   ╚══════╝╚══════╝
```

A combat-focused Mega Man / Hollow Knight-like Arena Battler built in Godot 4. This repository serves as a professional template for creating robust, scalable, and data-driven games, showcasing modern design patterns and a clean, testable architecture.

**Current Status:** Architecturally Stable & Feature-Rich.

---

<!-- TODO: Add a high-quality gameplay GIF here -->

## ■ Core Philosophy & Architectural Highlights

This project is built on a foundation of professional software design patterns, adapted for the Godot engine. The goal is a codebase that is easy to understand, maintain, and extend.

-   **Component-Based Entities:** All game entities (Player, Boss, Minions) are lean `BaseEntity` nodes that compose their functionality from small, single-responsibility components (`HealthComponent`, `PlayerPhysicsComponent`, etc.).

-   **Data-Driven Design:** Entity behavior is not hard-coded. It is defined in `Resource` files (`.tres`). `BossBehavior` and `MinionBehavior` resources act as "character sheets" that dictate stats, movement, and attack patterns, allowing designers to create new enemies without writing any code.

-   **Strategy Pattern for Logic:** Core behaviors like movement (`MovementLogic`) and attacks (`AttackLogic`) are implemented as interchangeable `Resource`-based strategies. This allows for complex combinations (e.g., a flying minion that uses a lunge attack) by simply linking different data files.

-   **Decoupled Systems via Service Locator & EventBus:** A central `ServiceLocator` provides safe, typed access to core singletons (`FXManager`, `ObjectPool`, etc.), while a global `EventBus` handles communication between systems, preventing tight coupling.

-   **Robust & Testable:** The architecture emphasizes testability, with a suite of unit tests, fakes for core systems (`FakeEventBus`), and a clear dependency injection pattern that makes components easy to test in isolation.

## ■ Getting Started

1.  **Install Godot 4.4** or newer.
2.  **Clone** this repository.
3.  Open the project in Godot and run the main scene: `res://src/scenes/main/main.tscn`.

## ■ Controls

The controls are designed for keyboard and mouse, reflecting the in-game controls menu.

-   **Movement:** Arrow Keys / WASD
-   **Primary Action (Jump/Confirm):** X / . / Space / Left-Click
-   **Secondary Action (Attack/Pogo):** C / , / Shift / Right-Click
-   **Tertiary Action (Dash):** Z / / / Ctrl / Middle-Click
-   **Heal:** Down + Jump (on ground)
-   **Pause / Menu:** Enter / P / Escape

## ■ Project Structure

The repository is organized to separate engine code, game logic, and data, making it easy to navigate.

-   `addons/` - Contains the GUT (Godot Unit Test) framework.
-   `docs/` - High-level design documents, architectural decision records (ADRs), and style guides.
-   `src/` - All core game source code.
    -   `api/` - "Interface" contracts (`IComponent`, `IDamageable`) and data transfer objects (`DamageInfo`).
    -   `arenas/` - (Placeholder for future arena-specific scenes/logic).
    -   `combat/` - Shared, reusable combat logic, such as `AttackLogic` resources.
    -   `core/` - Global systems, autoloaded singletons, and core utilities (`EventBus`, `ObjectPool`, `SceneManager`).
    -   `data/` - Global, game-wide data resources like the master `CombatConfig` and dialogue files.
    -   `entities/` - The heart of the gameplay, containing the Player, Boss, and Minion scenes, components, states, and behavior resources.
    -   `projectiles/` - Scenes and scripts for all projectiles.
    -   `scenes/` - The main game flow scenes (main menu, loading screen, encounter, game over).
    -   `shaders/` - All GLSL shader code.
    -   `tests/` - The complete suite of GUT unit and integration tests.
    -   `ui/` - All UI-related scenes and components (HUD, menus, debug overlay).
    -   `vfx/` - Visual effect scenes, like `hit_spark.tscn`.

## ■ Key Systems Overview

The game's architecture is managed by a suite of decoupled, autoloaded singletons.

-   `GameManager`: Manages the high-level game state.
-   `SceneManager`: Handles all scene transitions and ensures proper cleanup.
-   `EventBus`: A global message bus for loosely-coupled communication between systems.
-   `ObjectPool`: Manages pools of reusable nodes (projectiles, VFX) to prevent stuttering.
-   `ArenaBuilder`: Procedurally constructs the game level from `EncounterData` and `LevelLayout` resources.
-   `ServiceLocator`: Provides a central, type-safe access point to all other core systems.

For a deeper dive into the architecture, please see the documents in the `docs/` folder, especially `docs/ARCHITECTURE.txt`.

## ■ License

This project is licensed under the terms of the license agreement. Please see the `LICENSE` file for full details.