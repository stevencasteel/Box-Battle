# STYLE-001: GDScript Style Guide

**Date:** 2025-08-16
**Status:** Adopted

---

## Context

This document codifies the official style and formatting standards for all GDScript files in the project. The purpose is to maintain a cohesive, readable, and predictable codebase that is easy for any developer to navigate.

## Script Structure Standard

All `.gd` script files **MUST** adhere to the following structure and order:

1.  **File Path Header:** A single-line comment with the full `res://` path.
    ```gdscript
    # src/entities/player/player.gd
    ```
2.  **`@tool` Annotation:** If the script needs to run in the editor.
3.  **Class Docstring:** A multi-line `##` comment explaining the class's purpose.
4.  **`class_name` Declaration:** If applicable.
5.  **`extends` Declaration.**
6.  **Signals:** All `signal` definitions.
7.  **Enums:** All `enum` definitions.
8.  **Constants:** All `const` definitions.
9.  **`@export` Variables:** Grouped with `@export_group`.
10. **Node References:** All `@onready var` declarations.
11. **Public Member Variables:** Documented with a `##` comment.
12. **Private Member Variables:** Prefixed with an underscore `_`.
13. **Godot Lifecycle Methods:** `_ready`, `_process`, `_physics_process`, etc.
14. **Public Methods:** The primary API of the class.
15. **Private Methods:** Helper functions, prefixed with an underscore `_`.
16. **Signal Handlers:** All `_on_*` methods.

## Naming Conventions

-   **Classes & Nodes:** `PascalCase` (e.g., `Player`, `HealthComponent`).
-   **Files:** `snake_case` (e.g., `player.gd`, `health_component.gd`).
-   **Functions & Variables:** `snake_case` (e.g., `apply_damage`, `current_health`).
-   **Private Members:** `_snake_case` (e.g., `_player_node`).
-   **Constants & Enums:** `UPPER_SNAKE_CASE` (e.g., `CLOSE_RANGE_THRESHOLD`, `State.MOVE`).
-   **Interfaces:** `IPascalCase` (e.g., `IDamageable`, `IComponent`).

## Documentation

-   **Class Docstrings:** Use `##` on the lines before `class_name` to provide a high-level overview of the class's responsibility.
-   **Function/Variable Docstrings:** Use `##` on the line immediately preceding a function, signal, or public variable to generate an in-editor tooltip.
-   **Brevity:** Keep comments concise and focused on the "why," not the "what." The code should explain what it does; comments should explain why it does it that way.