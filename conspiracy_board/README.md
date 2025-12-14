# Conspiracy Board Module

## Overview
The Conspiracy Board is the central UI component for "The Pond" conspiracy investigation game. It provides a noir-aesthetic corkboard background where players can pin evidence, photos, and string connections.

## Features
- ✅ 1920x1080 corkboard background
- ✅ Warm brown noir aesthetic
- ✅ Vignette shader for depth effect
- ✅ Tunable visual parameters
- ✅ Comprehensive unit tests

## Structure
```
conspiracy_board/
├── scenes/
│   └── ConspiracyBoard.tscn      # Main board scene
├── scripts/
│   └── conspiracy_board.gd       # Board controller
├── shaders/
│   └── vignette.gdshader         # Depth effect shader
└── README.md                      # This file
```

## Usage

### Basic Setup
```gdscript
# Load and instantiate the board
var board_scene = preload("res://conspiracy_board/scenes/ConspiracyBoard.tscn")
var board = board_scene.instantiate()
add_child(board)
```

### Tunable Parameters

| Parameter | Type | Default | Range | Description |
|-----------|------|---------|-------|-------------|
| `vignette_strength` | float | 0.2 | 0.0 - 1.0 | Edge darkening intensity |
| `vignette_radius` | float | 0.8 | 0.0 - 1.0 | Vignette start radius |

### Runtime Configuration
```gdscript
# Adjust vignette effect
board.set_vignette_strength(0.3)
board.set_vignette_radius(0.7)

# Change background color
board.set_background_color(Color(0.6, 0.4, 0.3, 1.0))
```

## Technical Details

### Scene Hierarchy
```
ConspiracyBoard (Control)
├── Background (ColorRect)
│   └── [ShaderMaterial with vignette.gdshader]
└── ViewportContainer
    └── BoardViewport (SubViewport: 1920x1080)
```

### Shader Details
The vignette shader creates depth by darkening edges:
- Uses UV-based distance calculation from center
- Smooth falloff using `smoothstep`
- Configurable strength and radius
- Preserves warm brown background color

### Color Scheme
- **Background**: RGB(139, 90, 60) - Warm brown cork tone
- **Vignette**: Darkens edges for noir atmosphere
- **Alpha**: Fully opaque (1.0)

## Testing

Run tests using GUT (Godot Unit Test):
```bash
# From Godot editor or command line
godot --path . -s addons/gut/gut_cmdln.gd -gtest=res://tests/conspiracy_board/
```

### Test Coverage
- ✅ Scene loading verification
- ✅ Viewport dimensions (1920x1080)
- ✅ Background color validation
- ✅ Shader material existence
- ✅ Parameter clamping (0.0 - 1.0)
- ✅ Getter/setter methods
- ✅ Anchor and layout verification
- ✅ Z-index rendering order

## Integration

### Adding to Main Scene
```gdscript
# In your main game scene
@onready var conspiracy_board = $ConspiracyBoard

func _ready():
	# Board is ready to receive evidence items
	conspiracy_board.set_vignette_strength(0.25)
```

### Future Extensions
The board is designed to support:
- Evidence pins and items
- String connections between items
- Zoom and pan functionality
- Polaroid photos
- Note cards
- Investigation progress tracking

## Dependencies
- Godot 4.2+
- GUT (for unit testing)
- No external assets required (uses procedural background)

## Performance
- Lightweight shader effect
- Single ColorRect for background
- Minimal draw calls
- Suitable for 60 FPS gameplay

## Story Tracking
- **Epic**: Epic-003 Conspiracy Board UI
- **Story**: BOARD-004
- **Status**: ✅ Completed

## License
Part of "The Pond" game project.
