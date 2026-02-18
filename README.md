```markdown
# The Pond

A top-down bullet-hell shooter where you play as a frog battling hostile frogs in a pond ecosystem. Collect chemical upgrades powered by weaponized microplastics while surviving increasingly difficult enemy waves. Built with Godot 4.5.1, combining horde survival mechanics with environmental themes.

## Overview

The Pond is an action game featuring:
- **Combat System** - Bullet-hell mechanics with dynamic weapon upgrades
- **Horde Survival** - Progressively challenging enemy waves with difficulty scaling
- **Ecosystem Theme** - Environmental narrative integrated through gameplay and upgrades
- **Frog Protagonist** - Top-down movement and aiming mechanics in a pond environment

## Installation

### Prerequisites

- Godot Engine 4.5.1 or later
- Git

### Setup Steps

1. Clone the repository:
   ```bash
   git clone https://github.com/ArchitectVS7/the-pond.git
   cd the-pond
   ```

2. Open the project in Godot 4.5.1:
   - Launch Godot Engine
   - Click "Open Project"
   - Navigate to the cloned `the-pond` directory
   - Select `project.godot`

3. The project automatically loads with all dependencies configured. The GUT testing framework is included in `addons/gut/`.

## Usage

### Running the Game

Press **F5** or click the **Play** button in the top-right corner of the Godot editor to start the game.

To run a specific scene during development:
```bash
# Press F8 in the Godot editor and select your scene
```

### Game Controls

| Action | Input |
|--------|-------|
| Move | **WASD** |
| Aim | **Mouse** |
| Fire Weapon | **Left Click** |
| Interact with Upgrades | **Space** |

### Running Tests

Execute the test suite using the GUT framework:

```bash
godot --headless -s res://addons/gut/gut_cmdline.gd -gdir=res://tests
```

Test configuration is defined in `.gutconfig.json`. Tests validate combat systems, bullet behaviors, and core game state management.

### Building for Distribution

Export presets are configured in `export_presets.cfg`. To build:

1. In Godot editor, go to **Project → Export**
2. Select your target platform preset
3. Click **Export Project** and choose an output directory

Supported platforms are configured in the export presets file.

## Project Structure

```
the-pond/
├── combat/                 # Weapon systems, bullet behaviors, and enemy AI
├── core/                   # Game state management, EventBus autoload, core systems
├── shared/                 # Reusable managers, utilities, and common components
├── assets/                 # Game graphics, sprites, and audio resources
├── addons/                 # Godot plugins (GUT testing framework)
├── tests/                  # GUT-based unit tests for game systems
├── dev-docs/               # Developer documentation and architecture guides
├── .claude/                # AI assistant configuration, agents, and workflows
├── CLAUDE.md               # Repository conventions and development guidance
├── project.godot           # Godot project configuration
├── export_presets.cfg      # Export settings for building distribution packages
└── .gutconfig.json         # GUT test framework configuration
```

### Key Directories Explained

- **`combat/`** - Contains weapon systems, bullet mechanics, bullet behaviors, and enemy AI logic
- **`core/`** - Houses game state management, the EventBus autoload for signal handling, and initialization systems
- **`shared/`** - Provides reusable managers (event management, game state) and utility functions used across systems
- **`assets/`** - Organized game resources including graphics, sprites, and audio files
- **`tests/`** - GUT framework tests covering combat systems, bullet behaviors, and core game logic
- **`dev-docs/`** - Architecture decisions, system documentation, and development guides
- **`.claude/`** - Multi-agent workflow configuration for collaborative development assistance

## Development

### Architecture Overview

The Pond uses an event-driven architecture centered on the **EventBus** autoload:
- **Signal-based communication** - Systems communicate through EventBus signals for loose coupling
- **Combat system** - Modular weapon and bullet design supporting dynamic upgrades
- **State management** - Core game state accessible from all systems via autoloads

### Recent Changes

- **Godot 4.5.1 migration** - Updated file access APIs and removed deprecated FileAccess patterns
- **EventBus signal handling** - Enhanced cross-system communication with proper signal naming
- **Thread safety** - Added null checks for BulletUpHell thread cleanup on scene transitions
- **File operation handling** - Improved error handling for Godot 4.4+ FileAccess.store_string operations

### Code Organization Conventions

Refer to `CLAUDE.md` for detailed repository conventions, development workflows, and AI assistant guidance. This file documents:
- Code style and naming standards
- System architecture patterns
- Signal and event conventions
- Testing requirements for new features

## Contributing

When contributing, follow the conventions outlined in `CLAUDE.md`. Ensure:
- New combat features include unit tests in the `tests/` directory
- Signal usage follows EventBus conventions for consistency
- File operations include proper error handling for Godot 4.4+
- Changes are tested with: `godot --headless -s res://addons/gut/gut_cmdline.gd -gdir=res://tests`

## License

See repository for license information.
```