# ARCH-002: Refactoring Acceptance Criteria

**Date:** 2025-08-10

**Status:** Adopted

---

## Context

This document serves as a high-level checklist for our entire refactoring initiative. A sprint's work is considered "done" when it meets its specific criteria, and the entire initiative is "done" when all items on this list are checked.

## Global Acceptance Criteria

The refactoring is complete when all of the following are true:

### Architectural Health
- [ ] **Single Source of State:** All mutable runtime state (player data, game state) is managed via `Resource`-based data containers, eliminating the "dual architecture" of stateful singletons.
- [ ] **Standardized Configuration:** All tunable gameplay values are sourced from `.tres` `Resource` files, not `Constants.gd` or hardcoded magic numbers. A validation system checks for missing configs at startup.
- [ ] **Explicit Dependencies:** Core components (`HealthComponent`, `CombatComponent`, etc.) receive their dependencies via a `setup(config, services)` method, not by calling global singletons directly.
- [ ] **Clear Communication Rules:** The `EventBus` is used for global, cross-system messages. Godot signals are used for local, intra-scene communication. Direct calls between components are minimized or eliminated.

### Testing & Verification
- [ ] **Baseline Metrics Met:** The refactored game performs equal to or better than the baseline metrics established in `TEST-001_Baseline_Metrics.md`.
- [ ] **Regression Tests Pass:** The game successfully passes all manual checks in the `TEST-003_Regression_Checklist.md`.
- [ ] **Smoke Tests Pass:** The game is verifiably stable and key systems are functional as defined in `TEST-002_Smoke_Tests.md`.

### Code Quality & Documentation
- [ ] **No Dead Code:** All old, replaced systems and scripts have been safely removed from the project.
- [ ] **Documentation Updated:** All relevant architectural documents (`README.md`, ADRs) have been updated to reflect the new patterns.
- [ ] **Linter/Formatter Clean:** The entire codebase is formatted consistently and passes static analysis checks without warnings.
