# BOX BATTLE

```
██████╗  ██████╗ ██╗  ██╗    ██████╗  █████╗ ████████╗████████╗██╗     ███████╗
██╔══██╗██╔═══██╗╗██╗██╔╝    ██╔══██╗██╔══██╗╚══██╔══╝╚══██╔══╝██║     ██╔════╝
██████╔╝██║   ██║╚███╔╝      ██████╔╝███████║   ██║      ██║   ██║     █████╗  
██╔══██╗██║   ██║██╔██╗      ██╔══██╗██╔══██║   ██║      ██║   ██║     ██╔══╝  
██████╔╝╚██████╔╝██╔╝ ██╗    ██████╔╝██║  ██║   ██║      ██║   ███████╗███████╗
╚═════╝  ╚═════╝ ╚═╝  ╚═╝    ╚═════╝ ╚═╝  ╚═╝   ╚═╝      ╚═╝   ╚══════╝╚══════╝
```

A combat-focused 2D action game built in Godot 4. This repo contains the engine, gameplay systems, and tools used to produce a modular, maintainable boss-arena prototype.

**Current status (short):** Architecturally refactored and stabilized — unified state machines, componentized entities, data-driven config resources, and a small suite of robust core singletons (EventBus, SceneManager, Sequencer, ObjectPool, CombatUtils).

---

## Highlights (refactor & stability wins)
- Component-based entities (reusable components + `BaseStateMachine`/`BaseState`)
- Interface-driven damage (`IDamageable`) and `CombatUtils` for consistent damage application
- Data-driven tuning via `.tres` resources
- EventBus & Sequencer for decoupled communication and scripted sequences
- Performance improvements: async arena build, shader pre-warm, object pooling
- Key gameplay fixes: pogo mechanic, contact damage deduplication, consistent hit resolution

---

## Quick start (developer)
1. Install Godot 4.x (4.4+ recommended).  
2. Clone the repository.  
3. Open the project in Godot and run `res://scenes/main.tscn` (or the title screen).  
4. Dev tip: run the static script checker / lint from CI locally before pushing.

**Controls (default)**
- Move: WASD / Arrow keys  
- Jump: X  
- Attack: C  
- Dash: Z  
- Heal: Down + Jump (consumes charges)

---

## Repo layout (high level)

src/
├── core/ # singletons & infrastructure (EventBus, Sequencer, SceneManager, settings, etc.)
├── entities/ # players, bosses, components, state machines
├── projectiles/ # projectile implementations and pool usage
├── scenes/ # top-level scenes (game, main, loading)
├── ui/ # HUD & menu system (event-driven)
├── arenas/ # layout & encounter data + arena builder
docs/ # design, architecture, BUGS.txt, ADRs
core/ # core helpers & autoload scripts

---

## Where to read more (local docs)
- `docs/ARCHITECTURE.txt` — canonical architecture & runtime contracts (component, state machine, singletons).
- `docs/DESIGN.txt` — gameplay mechanics and rationale (pogo, hit logic, buffering).
- `BUGS.txt` — lightweight local bug board (Open / In Progress / Fixed).
- `core/DEPRECATION.md` — migration notes for deprecated APIs.

---

## Contributing / dev notes
- Follow the `ComponentInterface` contract for entity components.
- Clean up long-lived connections and timers on `_exit_tree` to avoid leaks.
- Use `.tres` resource files for tuning so designers can use the editor safely.
- Small PRs are preferred. Reference bug numbers (or BUGS.txt entries) in commit messages (eg. `Fixes #12`).

---

## How to commit docs quickly (VS Code)
1. Create a branch: `git checkout -b docs/refresh`  
2. Save files in the repo paths above.  
3. `git add <files>`  
4. `git commit -m "docs: refresh README + architecture + design + BUGS starter"`  
5. `git push --set-upstream origin docs/refresh` and open a PR if desired.

---

## License
CC0 1.0 Universal — public domain.
