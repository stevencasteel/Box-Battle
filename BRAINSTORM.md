# BRAINSTORM.md
**A free-form collection of random thoughts, creative ideas, and technical experiments. This is a judgment-free zone for capturing inspiration.**

---

## Mechanics Ideas
- **Multi-Stage Boss Health:** Boss HP is visually represented by "pie-slice" icons (e.g., 3/3). Instead of a standard health bar, players only see the state of the current slice.
    - **Feedback:** When a slice is close to breaking (e.g., within 5-10% HP), it could pulse and shake. When the threshold is passed, the slice shatters with a satisfying visual/audio effect.
    - **Progression:** Each time a slice breaks, the boss could enter a new phase: move faster, deal more damage, or unlock new attack patterns. This creates a clear difficulty ramp *within* the fight itself.
- **"Fizzle" Mechanic for Charged Shot:** If the player releases the attack button before the charge is complete, the charge dissipates with a minor "fizzle" sound and visual effect. This adds a layer of timing and risk to using the powerful charged shot.
- **Minion Enemies:** Introduce simpler, non-boss enemies to populate arenas.
    - **Behavior:** They could follow simple patrol paths (e.g., walk back and forth on a platform, turning at ledges or walls).
    - **Threat:** Primarily deal contact damage. Could potentially have a simple projectile attack in the future.

## Story/Narrative Thoughts
- **The "Determination" Concept:** The core healing mechanic is tied to the player's resolve. The act of attacking and facing danger head-on builds the "Determination" needed to survive. This is a strong thematic link between gameplay and narrative that should be emphasized.
- **Lore through a Wiki:** The game's story, character backstories, and world details could be expanded upon in an official GitHub Wiki, creating a deeper experience for engaged players.

## Technical Experiments & Advanced Concepts
- **`Path2D` for Boss Movement:** Explore using `Path2D` nodes to create highly scripted and cinematic boss movements. This would be perfect for:
    - Dash attacks that follow a specific curve.
    - Teleportation sequences where the boss moves along a hidden path.
    - Complex flight patterns for aerial bosses.
    - *Note:* `Path2D` is for *scripted* patterns, which is ideal for classic *Mega Man*-style bosses. `NavigationRegion2D` would be for more dynamic, reactive AI that chases the player, which is a different design direction.
- **Advanced Debug Modes:** Implement hotkey-activated debug overlays.
    - Toggling visibility of physics collision shapes.
    - Displaying the player's current state from the state machine.
    - Printing key variables (velocity, timers, etc.) to the screen in real-time.
- **Fixing "Head Bonk":** The player's rectangular `CollisionShape2D` can get caught on the corners of tiles. Investigate solutions:
    - Change the player's collision shape to a `CapsuleShape2D`.
    - Create a custom `CollisionPolygon2D` with beveled top corners.

## "What If..." Scenarios
- What if a pogo bounce on a projectile *reflected* it back at the boss?
- What if dashing through an enemy projectile destroyed the projectile but also consumed the dash (putting it on cooldown)?
- What if the player's charge shot had different properties based on how long it was charged (e.g., a small shot at 0.5s, a big one at 1s)?

## Questions to Explore
- How many healing charges should the player be able to store? Is one enough, or would two or three allow for more strategic options?
- What is the ideal patrol behavior for a basic minion? Should it be platform-bound, or should it be able to walk between multiple platforms?
- What are the most intuitive and satisfying visual cues for a boss telegraphing its attacks?

## Rejected Ideas (Keep for Reference)
*(This section is currently empty, but can be used to store ideas that were considered but ultimately decided against, along with the reasoning.)*