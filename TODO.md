# TODO.md
**Immediate work items and actionable tasks for the current development cycle.**

## High Priority - The Core Gameplay Loop
*These tasks are essential for making the core fight fun and functional.*

- [ ] **Evolve Boss AI (State Machine):**
    - [ ] Implement a basic state machine (`IDLE`, `PATROL`, `ATTACK`, `COOLDOWN`).
    - [ ] Implement platform-based patrol movement (walks on a platform until it hits a wall or ledge, then turns around).
    - [ ] Create a "volley" attack (fires 3 shots in a row).
    - [ ] Create a telegraphed lunge/dash attack.
- [ ] **Implement "Game Juice" (Feedback):**
    - [ ] Add a hit-flash effect (briefly modulate to white) for both player and boss on taking damage.
    - [ ] Implement a subtle screen shake function that can be called when the player takes damage.
    - [ ] Add placeholder SFX for player actions: jump, dash, melee swing, pogo bounce.
    - [ ] Add placeholder SFX for combat events: player/boss taking damage, projectile impact.
- [ ] **Build In-Game HUD:**
    - [ ] Create a new scene `GameHUD.tscn`.
    - [ ] Display player health (e.g., 5 squares).
    - [ ] Display a prominent boss health bar.
    - [ ] Display available healing charges.
- [ ] **Implement Win/Loss States:**
    - [ ] On player health <= 0, fade to a "Game Over" screen with "Retry" and "Quit" options.
    - [ ] On boss health <= 0, trigger a death sequence (e.g., freeze, explosion), show a "Victory!" screen, and then return to the title screen.

## Medium Priority - Polish and Core Feature Refinements
*Important tasks to tackle once the High Priority items are complete.*

- [ ] **Implement Debug Hotkeys:** Create a system toggled by the `Y, U, I, O` keys.
    - [ ] `Y`: Toggle Physics Shape visibility.
    - [ ] `U`: Toggle on-screen entity state display (e.g., player's current FSM state).
    - [ ] `I`: Toggle performance metrics (FPS counter).
    - [ ] `O`: (Future-proofed) Toggle AI visualization.
- [ ] **Fix "Head Bonk":** Investigate and fix player getting stuck on the corners of tiles when jumping.
- [ ] **Implement Charge Shot Fizzle:** If the attack button is released before a shot is fully charged, play a "fizzle" sound and a minor visual effect.
- [ ] **Add Charge Indicator:** Create a visual effect on the player sprite that appears and grows while the attack button is held down, indicating charge progress.

## Low Priority - "Nice-to-Have" Polish
*Tasks to work on once the vertical slice feels complete.*

- [ ] **Animate Entities:**
    - [ ] Add simple squash-and-stretch animations to the player for jumping/landing.
    - [ ] Create a simple particle effect for the player's dash.
- [ ] **Implement Scene Transitions:** Create a simple fade-to-black/fade-from-black scene transitioner for a smoother user experience.

## Code Quality
- [ ] Regularly review and refactor code after a feature is implemented to ensure it meets project standards.

## Testing Needed
- [ ] Thoroughly playtest the core boss fight after every High Priority task is completed to check for regressions.