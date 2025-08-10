# State Machine Flow Diagrams

**Date:** 2025-08-10

**Status:** Documented

---

This document provides a visual representation of the Finite State Machines (FSMs) for the core entities in the game. These diagrams are generated using Mermaid syntax and represent the logical flow of states based on player input and game physics.

## Player State Machine

The Player FSM is complex and responsive, designed to facilitate a fluid and expressive moveset. The core loop revolves around the `Move`, `Fall`, and `Jump` states, with multiple entry points into action states like `Dash` and `Attack`.

```mermaid
graph TD
    subgraph Core Movement
        MOVE <-->|Gravity/On Floor| FALL;
        MOVE -->|Jump Input| JUMP;
        FALL -->|Coyote Time Jump| JUMP;
        JUMP -->|Apex Reached| FALL;
    end

    subgraph Wall Interaction
        FALL -->|Holding Direction into Wall| WALL_SLIDE;
        JUMP -->|Holding Direction into Wall| WALL_SLIDE;
        WALL_SLIDE -->|Jump Input| JUMP;
        WALL_SLIDE -->|Not Holding Direction| FALL;
    end

    subgraph Action States
        MOVE --> DASH;
        FALL --> DASH;
        JUMP --> DASH;
        WALL_SLIDE --> DASH;
        DASH -->|Duration Ends| FALL;

        MOVE --> ATTACK;
        FALL --> ATTACK;
        JUMP --> ATTACK;
        WALL_SLIDE --> ATTACK;
        ATTACK -->|Duration Ends| FALL;
    end

    subgraph Special States
        ANY_STATE[Any State] -->|Takes Damage| HURT;
        HURT -->|Knockback Ends| FALL;
        MOVE -->|Hold Heal Buttons| HEAL;
        HEAL -->|Buttons Released| MOVE;
    end

    style MOVE fill:#cde4f0,stroke:#333,stroke-width:2px
    style FALL fill:#cde4f0,stroke:#333,stroke-width:2px
    style JUMP fill:#cde4f0,stroke:#333,stroke-width:2px
    style WALL_SLIDE fill:#e8d1e8,stroke:#333,stroke-width:2px
    style DASH fill:#f0e4cd,stroke:#333,stroke-width:2px
    style ATTACK fill:#f0e4cd,stroke:#333,stroke-width:2px
    style HURT fill:#f8cbcb,stroke:#333,stroke-width:2px
    style HEAL fill:#d1e8d1,stroke:#333,stroke-width:2px


## Boss State Machine

The Base Boss FSM is a simple, predictable loop designed as a template for more complex behaviors. It cycles cleanly through its states based on timers.


graph TD
    COOLDOWN -->|Cooldown Timer Finishes| PATROL;
    PATROL -->|Patrol Timer Finishes| IDLE;
    IDLE -->|Immediately| ATTACK;
    ATTACK -->|Immediately| COOLDOWN;

    style COOLDOWN fill:#cde4f0,stroke:#333,stroke-width:2px
    style PATROL fill:#e8d1e8,stroke:#333,stroke-width:2px
    style IDLE fill:#f0e4cd,stroke:#333,stroke-width:2px
    style ATTACK fill:#f8cbcb,stroke:#333,stroke-width:2px
