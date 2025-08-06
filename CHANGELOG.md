# Changelog
All notable changes to this project will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/), and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

---

## [Unreleased]
*Changes for the next version will be documented here.*

### Added
- 

### Changed
- 

### Fixed
- 

---

## [0.1.0] - 2025-08-05
*This version marks a major architectural overhaul, transforming the project from a functional prototype into a robust and scalable foundation.*

### Added
- **Player Character:** Implemented a `CharacterBody2D` player with a rich moveset including running, jumping, dashing, wall-sliding, and wall-jumping.
- **Combat System:** Created a combat system featuring a standard melee attack, a chargeable projectile, and a pogo-bounce attack.
- **"Determination" Healing Mechanic:** Added a unique healing system where dealing damage builds "determination" to earn healing charges.
- **Data-Driven Arenas:** Established a system for defining arena layouts and encounters in separate data-only scripts.
- **Basic Boss Entity:** Created a foundational boss enemy with health and a basic projectile attack.
- **Reusable Menu System:** Built a powerful, component-based menu manager (`MenuManager.gd`) for creating fully navigable UI screens.
- **Project Documentation:** Created the initial framework for project management and documentation (`TODO`, `ROADMAP`, `DESIGN`, etc.).

### Changed
- **Complete Architectural Refactor:** Overhauled the project's structure to use professional design patterns.
    - **Player Logic:** Replaced an ad-hoc system of boolean flags with a formal, enum-based **Finite State Machine (FSM)**, which strictly defines player states (`MOVE`, `ATTACK`, `HURT`, etc.) to prevent conflicts and improve stability.
    - **Global Singletons:** Eliminated hardcoded values by centralizing them into global singletons.
        - Game balance values (e.g., player speed, gravity, health) were moved to `Constants.gd`.
        - Asset file paths ("magic strings") were moved to `AssetPaths.gd` to prevent broken references.
- **File Organization:** Restructured the project's directories to be more feature-based and intuitive (e.g., `core`, `entities`, `scenes`, `ui`).

### Fixed
- **Contact Damage:** Fixed a critical bug where the refactored player `collision_mask` prevented them from taking contact damage.
- **Pogo Mechanic:** Fully restored the pogo-bounce functionality, fixing the lack of an immediate bounce on static surfaces and re-enabling bounces on enemy projectiles.
- **One-Way Platforms:** Corrected the collision shape position and restored the player's drop-through logic, making the platforms fully functional.