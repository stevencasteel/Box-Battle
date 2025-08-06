# BOX BATTLE

```
██████╗  ██████╗ ██╗  ██╗    ██████╗  █████╗ ████████╗████████╗██╗     ███████╗
██╔══██╗██╔═══██╗╗██╗██╔╝    ██╔══██╗██╔══██╗╚══██╔══╝╚══██╔══╝██║     ██╔════╝
██████╔╝██║   ██║╚███╔╝      ██████╔╝███████║   ██║      ██║   ██║     █████╗  
██╔══██╗██║   ██║██╔██╗      ██╔══██╗██╔══██║   ██║      ██║   ██║     ██╔══╝  
██████╔╝╚██████╔╝██╔╝ ██╗    ██████╔╝██║  ██║   ██║      ██║   ███████╗███████╗
╚═════╝  ╚═════╝ ╚═╝  ╚═╝    ╚═════╝ ╚═╝  ╚═╝   ╚═╝      ╚═╝   ╚══════╝╚══════╝
```

A combat-focused 2D action game built in Godot 4, showcasing clean architecture and comprehensive game systems.

## What Makes This Code Notable

### Architectural Excellence
- **Centralized Asset Management**: All file paths are managed through a single `AssetPaths` singleton, eliminating broken references and making refactoring trivial
- **Singleton-Based Core Systems**: Audio, settings, cursor management, and constants are globally accessible without tight coupling
- **Modular Arena System**: Level layouts and encounters are separated into data-only scripts, making level creation declarative and maintainable

### Advanced Player Controller
- **Robust State Machine**: Clean finite state machine handling movement, combat, dashing, wall-sliding, and healing states
- **Physics-Driven Design**: Implements coyote time, jump buffering, wall jumping, and variable jump height for responsive controls
- **Pogo Mechanics**: Sophisticated downward attack system with instant collision detection and momentum preservation
- **Determination System**: Risk/reward mechanics where dealing damage builds healing charges

### Production-Quality UI
- **Custom Menu Navigation**: Unified system supporting both keyboard and mouse input with audio feedback
- **Global HUD Management**: Context-aware UI elements that appear/disappear based on current scene
- **Real-time Settings Sync**: Audio sliders and checkboxes update immediately without save/load cycles
- **Custom Slider Component**: Self-contained, reusable UI widget with proper mouse interaction

### Smart Audio Architecture
- **Pooled SFX Players**: Multiple AudioStreamPlayer instances prevent sound cutoff during rapid-fire events
- **Context-Aware Sounds**: Different menu actions trigger appropriate audio cues (back vs select vs error)
- **Robust Music Management**: Prevents music restarts when switching between menu screens

### Clean Code Practices
- **Extensive Documentation**: Every script explains its purpose and key design decisions
- **Consistent Naming**: Clear, descriptive variable and function names throughout
- **Proper Signal Usage**: Decoupled communication between components using Godot's signal system
- **Layer-Based Physics**: Thoughtful collision layer setup for different object types and interactions

### Noteworthy Technical Solutions
- **Fake Cursor System**: Custom cursor that works consistently across all platforms with proper click-through behavior
- **Immediate Pogo Detection**: Proactive collision checking prevents frame-delay issues in fast-paced combat
- **Hazard Dual-Layer System**: Terrain that's both solid (world layer) and damaging (hazard layer) for consistent physics
- **Deferred Scene Changes**: Proper scene transition handling to prevent physics errors

## Getting Started

1. Clone the repository
2. Open the project in Godot 4.4+
3. Run the project - it starts at the title screen

## Controls

- **Movement**: WASD / Arrow Keys
- **Jump**: Space / X / Period
- **Attack**: C / Comma / Alt + Shift
- **Dash**: Z / Slash / Shift + Ctrl
- **Heal**: Hold Down + Jump while on ground (requires healing charges)

## Project Structure

```
src/
├── core/           # Singleton systems (audio, settings, etc.)
├── entities/       # Player and enemy classes
├── projectiles/    # Bullet and shot behaviors
├── scenes/         # Main game scenes
├── ui/             # Menu systems and components
└── arenas/         # Level data and encounter scripts
```

This codebase demonstrates how to structure a Godot project for maintainability, extensibility, and professional polish. Every system is designed to be modular, well-documented, and easy to extend.

## License

This project is released under CC0 1.0 Universal - dedicated to the public domain. Use it however you like!