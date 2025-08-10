# Project Deprecation Map

This document tracks major file renames and moves across the entire project.

| Old Path | New Path | Reason | Date | Migration Note |
|---|---|---|---|---|
| `res://src/core/Config.gd` | `res://src/core/data/config/config.gd` | Architectural refactor | 2025-08-10 | Autoload path updated in `project.godot`. No script changes required. |
| `res://src/core/settings.gd` | `res://src/core/data/config/settings.gd` | Architectural refactor | 2025-08-10 | Autoload path updated in `project.godot`. No script changes required. |
| `res://src/core/events/*_event.gd` | `res://src/core/events/typed_events/*_event.gd` | Architectural refactor | 2025-08-10 | Update `preload` or `load` paths in scripts if referenced directly. |