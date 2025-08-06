# ARCHITECTURE.md
**A high-level overview of the project's technical structure, coding standards, and core design patterns. This document explains *how* the game is built.**

---

## Project Structure
The project follows a clean, feature-based directory structure within the `/src` folder to ensure code is organized, scalable, and easy to navigate.

- **/src/core:** Contains global, project-wide systems implemented as Autoload Singletons. These manage game state and functionality that needs to be accessible from anywhere (e.g., Audio, Settings, Constants).
- **/src/entities:** Contains the scripts and scenes for all interactive game characters, such as the Player and Bosses. Each entity is self-contained in its own sub-folder.
- **/src/projectiles:** Contains the scripts and scenes for all projectiles fired by entities.
- **/src/scenes:** Contains the primary game state scenes, such as the main game level (`game.tscn`) and the initial entry point (`main.tscn`).
- **/src/ui:** Contains all user interface elements, organized by function:
    - **/components:** Reusable, self-contained UI widgets (e.g., `CustomSlider`).
    - **/global_hud:** The autoloaded global HUD.
    - **/menu_manager:** The reusable system for menu navigation.
    - **/screens:** The individual scenes for each menu screen (Title, Options, etc.).
- **/src/arenas:** Contains the data-only scripts that define the layout (`_layout.gd`) and enemy composition (`_encounter.gd`) for each battle arena.

---

## Design Patterns Used
- **Singleton Pattern (Autoloads):** Used extensively for globally accessible systems, preventing the need to pass references through the scene tree.
    - `Settings.gd`: Manages persistent game settings like volume levels.
    - `AudioManager.gd`: A centralized manager for all audio playback.
    - `CursorManager.gd`: Manages the state and appearance of the custom mouse cursor.
    - `Constants.gd`: A central repository for game design and physics values (e.g., `GRAVITY`, `PLAYER_SPEED`) for easy tuning.
    - `AssetPaths.gd`: A static registry of all critical asset file paths to prevent broken references if files are moved.
- **State Machine:** The Player's behavior is managed by a formal, enum-based state machine within `player.gd`. This enforces that the player can only be in one state at a time (e.g., `MOVE`, `ATTACK`, `HURT`), preventing conflicting actions and simplifying the addition of state-specific logic like animations and sounds.
- **Component-Based UI:** The UI is built from self-contained, reusable scenes and scripts. `MenuManager.gd` and `CustomSlider.gd` are treated as components that can be dropped into any menu scene to provide complex functionality without the scene needing to know their internal implementation.
- **Data-Driven Level Design:** Arena layouts and encounters are defined in separate data-only scripts (`arena_00_layout.gd`, `arena_00_encounter.gd`). The main `game.gd` scene reads from these files to procedurally build the level, allowing for rapid creation of new arenas without duplicating scene files.

---

## Coding Standards
- **Naming Conventions:**
    - `PascalCase` for class names, scene names, and `.gd` script files (e.g., `Player.gd`, `OptionsMenu.tscn`).
    - `snake_case` for functions and variables (e.g., `_physics_process`, `coyote_timer`).
    - `SCREAMING_SNAKE_CASE` for constants (e.g., `PLAYER_MAX_HEALTH`).
- **Asset Management:** All file paths for scenes, scripts, and assets loaded in code **must** be referenced through the `AssetPaths.gd` singleton.
- **Scene Instantiation:** Use `const` variables to `preload` scenes that will be instantiated frequently (e.g., projectiles).
- **Collaboration Workflow (Human-AI):**
    1.  **Define Goal:** The Human defines a clear, small, and achievable goal for the next step.
    2.  **AI Solution:** The AI provides a code solution, **always regenerating complete files**. The AI must also clearly explain the reasoning behind the changes.
    3.  **Implement & Test:** The Human implements the code and performs thorough testing to ensure the feature works perfectly and has not caused any regressions.
    4.  **Commit & Push:** Once verified, the Human commits the changes with a descriptive message (e.g., via the VS Code Source Control panel) and **pushes the commit** to the remote Git repository.
    5.  **Confirm & Proceed:** The Human confirms the successful push and that the task is complete, then defines the next goal. This iterative "commit-and-confirm" loop ensures stability and creates a reliable project history.

---

## Performance Considerations
- **Preloading:** Key assets and scenes are preloaded into memory using `const` variables at script parse time, preventing stutter during gameplay.
- **Deferred Calls:** `call_deferred()` is used for actions that could destabilize the physics or scene tree if performed mid-frame, such as disabling a collision shape immediately after it's used.
- **Audio Pooling:** The `AudioManager` maintains a small pool of `AudioStreamPlayer` nodes to reuse for sound effects, which is more performant than creating and destroying a node for every SFX played.