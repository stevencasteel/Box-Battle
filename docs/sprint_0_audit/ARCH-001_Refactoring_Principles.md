# ARCH-001: Refactoring Principles

**Date:** 2025-08-10

**Status:** Adopted

---

## Context

To ensure our refactoring effort is focused, consistent, and successful, we must operate from a shared set of guiding principles. These principles will act as a tie-breaker when design decisions are unclear and will define the target state of our architecture.

## Guiding Principles

1.  **Work *With* the Engine, Not Against It.**
    *   **Rationale:** Our attempt to force a classic DI pattern failed because it fought Godot's startup lifecycle. All future architectural decisions must respect and leverage Godot's idiomatic patterns (nodes, scenes, signals, resources).
    *   **In Practice:** We will prefer solutions that feel natural in Godot over patterns that require complex workarounds to function.

2.  **Every Change Must Be Verifiable.**
    *   **Rationale:** Refactoring without testing is just moving code around. To prevent regressions, every significant change must be accompanied by a clear method of verification.
    *   **In Practice:** This means creating smoke tests, regression checklists, and eventually, automated unit tests. We will use the documents `TEST-002` and `TEST-003` to track this.

3.  **Prioritize Decoupling and Explicit Dependencies.**
    *   **Rationale:** The primary weakness of the current Service Locator pattern is that dependencies are hidden. Our goal is to make dependencies explicit.
    *   **In Practice:** Components and systems should receive their dependencies through a `setup()` method where possible, rather than calling global singletons in their internal logic. Communication should favor events (`EventBus`) for global messages and signals for local, parent-child messages.

4.  **Standardize Patterns; Eliminate "Dual Architectures".**
    *   **Rationale:** The audit identified several areas (state management, configuration) where two different patterns exist to solve the same problem. This increases cognitive load and maintenance cost.
    *   **In Practice:** We will choose a single, standard way to manage state (the `Resource`-based data pattern) and a single way to manage configuration (`tres` config resources), and migrate all existing code to these standards.

5.  **The Strangler Fig Pattern: Migrate Incrementally.**
    *   **Rationale:** Big-bang rewrites are risky and prone to failure. We will adopt the Strangler Fig pattern.
    *   **In Practice:** We will create the new, improved system alongside the old one. We will then migrate dependencies one by one to the new system. Once all dependencies are migrated, we can safely delete the old system. This ensures the game remains functional throughout the entire process.
