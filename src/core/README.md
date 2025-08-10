# Core Subsystem

This directory contains all of the project's global systems, singletons, and core logic that is not specific to a single entity or scene.

## Subdirectories

-   **/building**: Contains the classes responsible for procedural level generation (`ArenaBuilder`, `LevelParser`, etc.).
-   **/data**: Manages game data, including the new `Resource`-based configurations.
-   **/events**: Contains the global `EventBus` and all typed event definitions.
-   **/sequencing**: Manages the `Sequencer` for creating scripted, timed events.
-   **/systems**: Contains the primary global managers (`AudioManager`, `GameManager`, etc.).
-   **/util**: A collection of stateless utility singletons like `AssetPaths` and `Palette`.

## Autoloaded Singletons (Global Access)

The following scripts are registered as autoloads in `project.godot` and can be accessed globally:

-   `Settings`: Manages persistent game settings.
-   `AudioManager`: Controls all audio playback.
-   `CursorManager`: Manages the custom mouse cursor.
-   `Constants`: Holds engine-level constants.
-   `AssetPaths`: Provides safe, static paths to all project assets.
-   `GlobalHud`: The persistent UI layer for global elements.
-   `GameManager`: Manages game state and scene flow.
-   `ArenaBuilder`: The main entry point for level construction.
-   `EventBus`: The global event dispatcher.
-   `Sequencer`: Manages timed event sequences.
-   `Config`: Handles loading data from `Resource`-based configs.
-   `Palette`: Defines the global color scheme.
-   `ObjectPool`: Manages reusable nodes to improve performance.
-   `PhysicsLayers`: Provides named constants for physics collision layers.

## Public API

The primary public API for inter-system communication is the `EventBus`. Systems should emit events to signal state changes and listen for events to react to them, rather than calling each other directly.