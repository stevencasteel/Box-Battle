# Core Subsystem Deprecation Map

This document tracks file renames and moves specifically within `src/core`.

| Old Path | New Path | Reason | Date | Migration Note |
|---|---|---|---|---|
| `res://src/core/data/Config.gd` | `res://src/core/data/config/config.gd` | Naming convention and grouping. | 2025-08-10 | Autoload path was updated in `project.godot`. |
| `res://src/core/data/settings.gd` | `res://src/core/data/config/settings.gd` | Grouped with other data configs. | 2025-08-10 | Autoload path was updated in `project.godot`. |