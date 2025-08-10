# ADR-001: Global System Access via Autoload Singletons (Service Locator)

**Date:** 2025-08-10

**Status:** Accepted (Existing Pattern)

---

## Context

The project requires numerous cross-cutting services that need to be accessible from various parts of the codebase. These include core systems (EventBus, AudioManager, ObjectPool), data providers (Config, Settings, Palette), and utility services (AssetPaths, PhysicsLayers).

A simple and idiomatic way to achieve this in Godot is by using the **Autoload** feature, which creates a globally accessible singleton instance of a script or scene. This effectively implements the **Service Locator** design pattern, where any node in the game can directly access a service by its global name (e.g., `EventBus.emit()`, `Config.get_value()`).

## Decision

We will use the Godot Autoload (Service Locator) pattern as the primary mechanism for providing global services throughout the application.

This decision was made because it is the most direct, performant, and engine-idiomatic way to solve the problem of global access in Godot 4. It avoids the need for complex dependency injection frameworks or manual "prop-drilling" of dependencies through the node tree.

The audit file `singleton_map.txt` confirms there are currently 14 such services registered in `project.godot`.

## Consequences

### Positive:
-   **Simplicity & Speed:** Accessing a service is trivial (`ServiceName.method()`). There is no setup boilerplate required in consumer scripts.
-   **Performance:** Autoloads are instantiated once at startup, providing fast and reliable access.
-   **Decoupling:** Systems can communicate through a central service like `EventBus` without needing direct references to each other, as shown in `event_usage.txt`.

### Negative (Risks & Architectural Debt):
-   **Hidden Dependencies:** The dependencies of a script are not explicitly declared in its API. To know that `player.gd` depends on `Config`, one must read the entire script body. This makes the code harder to reason about.
-   **Difficult to Test:** This is the most significant drawback. It is very difficult to unit-test a script that calls a global singleton. You cannot easily replace `EventBus` with a "mock" or "fake" version for a test, which was the root cause of the failed DI refactor attempt.
-   **Risk of Tight Coupling:** Because services are so easy to access, it can encourage developers to create a "spaghetti" architecture where everything calls everything else, bypassing more structured communication patterns.
-   **Configuration Fragility:** The heavy reliance on string-based keys for services like `Config` and `EventBus` is fragile. A typo will result in a runtime error, not a compile-time one. The `config_usage.txt` file shows dozens of such calls, each being a potential point of failure.

---

## Next Steps (Refactoring Plan)

This pattern, while accepted, is the primary target for refinement in our upcoming refactoring sprints. The plan is not to eliminate autoloads, but to mitigate their negative consequences by:
1.  **Standardizing Configuration (Sprint 1):** Introduce validation to catch bad config paths at startup.
2.  **Unifying Data Architecture (Sprint 2):** Reduce the number of singletons that hold mutable state.
3.  **Refining Communication (Sprint 3):** Clarify when to use `EventBus` versus other patterns to reduce the risk of "spaghetti" code.
