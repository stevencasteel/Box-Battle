# DESIGN.md
**The official documentation for the game's design decisions, mechanics, and core philosophies. This serves as the single source of truth for how the game works and feels.**

---

## Design Philosophy
- **Tough but Fair:** The game is designed to be challenging. Enemies and bosses will have learnable patterns. Player failure should feel like a learning opportunity, not a punishment.
- **Player Expression:** The player is given a rich and responsive moveset (jump, dash, wall-slide, pogo, charged shot). Mastery of these movement options is key to success.
- **Thematic Mechanics:** Core gameplay systems are tied to the game's narrative concepts. For example, aggression is rewarded with the ability to heal via "Determination."
- **Minimalist Clarity:** The UI and gameplay indicators should provide necessary information without cluttering the screen.
- **Human-AI Collaborative Design:** The level design process is intended to be collaborative between a human designer and an AI assistant. The human-readable coordinate system in the level layout files facilitates this workflow.

---

## Core Mechanics

### Player Movement
- **Standard Controls:** The player has standard run, jump, and air-jump capabilities.
- **Advanced Techniques:**
    - **Coyote Time:** The player can still jump for a fraction of a second after running off a ledge, making platforming feel more forgiving.
    - **Jump Buffering:** A jump input is registered slightly before landing, making jumps feel responsive.
    - **Dashing:** A quick, fixed-distance burst of speed in 8 directions. It has a short cooldown to prevent spamming.
    - **Wall-Sliding & Wall-Jumping:** The player can slide down walls and perform a powerful jump off them, enabling vertical traversal.
    - **Drop-Through Platforms:** The player can drop down through specially marked platforms by pressing `Down + Jump`.

### Combat System
- **Primary Attack (Melee):** A quick, short-range attack that can be performed horizontally or vertically.
- **Secondary Attack (Charged Shot):** Holding the attack button charges a powerful, long-range projectile.
    - **Charge Fizzle:** Releasing the charge too early results in a "fizzle" with no projectile, creating a risk/reward dynamic.
- **Pogo Attack:** A downward melee attack in the air allows the player to bounce off enemies, projectiles, and hazards, resetting their aerial abilities. This is a key tool for both offense and mobility.
- **Hitbox/Hurtbox System:** Player attacks are managed by a `Hitbox` (what deals damage), and vulnerability is managed by a `Hurtbox` (what takes damage). This allows for precise and distinct collision interactions.

### Health and Healing: The Determination System
- **Philosophy:** Healing is not passive. It is a resource earned directly through successful combat, pushing an offensive playstyle.
- **Determination:** Dealing damage to enemies fills a `determination_counter`.
- **Healing Charges:** Once the counter is full, it resets and grants the player one `healing_charge`.
- **The Healing Act:** The player can consume a charge to heal one point of health by standing still on the ground and holding `Down + Jump`. This action takes time and leaves the player vulnerable, making it a strategic decision during a fight.

### Boss Design
- **Health System ("Corner Armor"):** Boss health will be visually represented by three "armor plates" capping the corners of the main square body.
    - Each plate represents a health stage. When a stage's HP is depleted, the corresponding armor plate shatters with strong visual/audio feedback.
    - As a plate nears depletion, it will visually pulse and shake to telegraph the upcoming break.
    - Each time a plate shatters, the boss will enter a new phase, increasing its speed, damage, or unlocking new attack patterns.
- **Pattern-Based AI:** Bosses are not random. They follow strict, learnable patterns, encouraging player mastery and observation.

---

## UI/UX Decisions
- **Minimalist Game HUD:** The in-game HUD will only show essential combat information (Player Health, Boss Health, Healing Charges).
- **Clear Menu Navigation:** Menus utilize visual cursors and sound effects for keyboard, controller, and mouse navigation, ensuring a consistent and intuitive user experience.