# ROADMAP.md
**The long-term vision and planned features for the project. This document outlines the major milestones, from the initial polished demo to a full game.**

---

## Version 1.0 Goals - "The Polished Vertical Slice"
*The primary objective is to create a single, complete, and highly polished gameplay loop that serves as a benchmark for the entire game.*

- [ ] **A Dynamic and Challenging Primary Boss:** The boss in Arena 00 is fully functional with multiple, telegraphed attack patterns (e.g., volley, lunge) and basic AI (patrolling, facing the player).
- [ ] **Fully Functional In-Game HUD:** The player has clear and intuitive displays for their health, the boss's health, and available healing charges.
- [ ] **Satisfying Player Feedback ("Juice"):** All core player and combat actions are accompanied by appropriate sound effects, visual effects (hit-flash, particles), and screen shake. The game *feels* good to play.
- [ ] **A Complete Gameplay Flow:** The player can start from the title screen, enter the game, fight the boss, and reach a clear "Victory" or "Game Over" screen, with smooth transitions between states.

---

## Future Versions

### v1.1 - "The Content Expansion"
*Once the vertical slice is complete, the focus will shift to expanding the amount of content and adding a new dimension to combat.*

- [ ] **Introduce a Second Arena & Boss:** Design and implement `Arena_01` with a new boss that has a distinct moveset (e.g., a flying or more agile enemy).
- [ ] **Introduce a "Minion" Enemy Type:** Create a simple, weaker enemy that can be placed in arenas to add variety to encounters. This enemy will patrol a platform and deal contact damage.
- [ ] **Refine Player Combat Indicators:**
    - [ ] Implement the "fizzle" effect for releasing a charge shot too early.
    - [ ] Add the visual indicator to the player to show when their charge shot is ready.

### v2.0 - "The Full Game Loop"
*This version aims to transform the project from a series of encounters into a cohesive game with progression.*

- [ ] **Implement a Stage Select Screen:** Create a central hub where the player can choose which arena/boss to challenge.
- [ ] **Basic Progression:** Defeating a boss could unlock the next stage.
- [ ] **Introduce More Enemy Variety:** Add 1-2 more enemy types with different behaviors (e.g., a stationary turret enemy).

---

## Dream Features
*A "blue sky" list of exciting ideas to explore once the core game is robust and feature-complete. These are not committed plans but serve as inspiration.*

- [ ] **Advanced Boss Mechanics:**
    - [ ] Implement the multi-stage boss health system with "pie-slice" indicators that shatter at damage thresholds, changing the boss's attack patterns and speed.
    - [ ] Use `Path2D` to create complex, cinematic boss movements and attack trajectories.
- [ ] **Expanded Player Abilities:** Introduce a new weapon or ability that is awarded for defeating a boss, in classic *Mega Man* style.
- [ ] **Deeper Lore & Narrative:** Weave a simple story through item descriptions or short pre/post-battle dialogues. Further develop the "Determination" concept.
- [ ] **Official Wiki:** Create and maintain a GitHub Wiki for the project to formally document lore, mechanics, and development history for the community.
- [ ] **Robust Debug Tools:** Expand the debug overlay with more features, accessible via hotkeys.