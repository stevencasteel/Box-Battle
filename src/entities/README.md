# Entities

This directory contains the logic for all dynamic game objects, such as the Player and Bosses.

## Architecture

Entities follow a **Component-Based Architecture** combined with a **State Machine**.

-   **Context Node (`player.gd`, `base_boss.gd`)**: The root node of the entity scene. Its primary job is to hold the components and manage the current state. It delegates all logic to its children.
-   **Data Resource (`player_state_data.gd`)**: A `Resource` file that holds all of the entity's state variables (health, timers, flags). This allows states and components to share data without needing a direct reference to the main node or each other.
-   **Components (`health_component.gd`, etc.)**: Child nodes that encapsulate a single area of responsibility (e.g., managing health, handling input). They operate on the shared `Data Resource`.
-   **States (`state_move.gd`, etc.)**: Classes that define specific behaviors. The active state is managed by the Context Node.

## Adding a New State

1.  Create a new script in the entity's `states` directory that inherits from `PlayerState` or `BossState`.
2.  Implement the required `enter()`, `exit()`, and `process_physics()` methods.
3.  Add the new state to the `State` enum in the context node script (`player.gd`).
4.  Instantiate the new state in the `states` dictionary in the context node's `_ready()` function.
5.  Call `change_state(State.YOUR_NEW_STATE)` from another state to transition to it.