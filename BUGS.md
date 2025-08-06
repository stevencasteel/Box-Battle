# BUGS.md
**A tracker for all known issues, their status, and their solutions. This provides a clear overview of the project's health.**

---

## Critical (Blocks Progress)
*No critical bugs are currently known.*

## High Priority
- [ ] **[BUG-003]** Drop-through platforms ("-") are not functioning correctly.
  - **Found:** 2025-08-05
  - **Status:** Open
  - **Details:** The player cannot drop down through one-way platforms by pressing Down + Jump. The code for this was not implemented in the new player state machine.

## Medium Priority
- [ ] **[BUG-001]** Player character's collision shape can get stuck on tile corners when jumping up against them, halting momentum.
  - **Found:** 2025-08-05
  - **Status:** Open
  - **Details:** When the player jumps and moves horizontally against a wall, their top corner can clip the bottom corner of a tile above them, causing them to "bonk" their head and fall immediately. This feels jarring and unfair. The cause is likely the perfectly rectangular shape of the player's `CollisionShape2D`.

## Low Priority / Minor
*No low-priority bugs are currently known.*

---

## Fixed (Keep for Reference)
- [x] **[BUG-F002]** The player's pogo attack was not working correctly on all surfaces.
  - **Fixed:** 2025-08-05
  - **Solution:** Re-implemented the `_check_for_immediate_pogo()` physics query from the pre-refactor code to allow instant bounces on surfaces directly below the player. Also updated the `_trigger_pogo()` function to correctly handle bouncing on enemy projectiles (`is_in_group("enemy_projectile")`) in addition to enemies with a `take_damage()` method.

- [x] **[BUG-F001]** The player was not taking contact damage from the boss or hazard tiles.
  - **Fixed:** 2025-08-05
  - **Solution:** During the state machine refactor, the player's `CharacterBody2D` `collision_mask` was changed to ignore the "enemy" and "hazard" layers. The mask was updated in `player.tscn` to correctly detect these layers again, allowing the existing `_check_for_contact_damage()` function to work as intended.