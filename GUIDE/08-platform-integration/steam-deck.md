# Steam Deck

Steam Deck support is first-class in The Pond. The game detects Deck hardware, applies optimizations, and uses appropriate control mappings.

---

## Detection

**File**: `core/scripts/input_manager.gd`

```gdscript
func _detect_platform() -> void:
    # Check for Steam Deck
    if OS.has_environment("STEAM_DECK"):
        is_steam_deck = true
        current_device = DeviceType.STEAM_DECK
        push_warning("InputManager: Running on Steam Deck")
```

The `STEAM_DECK` environment variable is set by SteamOS when running on Deck hardware.

---

## Performance Targets

| Metric | Target | Notes |
|--------|--------|-------|
| Resolution | 1280x800 | Deck native |
| Frame rate | 55+ fps | 40Hz acceptable |
| Battery | 2+ hours | Normal gameplay |
| Thermals | Stable | No throttling |

### Baseline Test Scenarios

| Scenario | Enemy Count | Bullet Count | Target FPS |
|----------|-------------|--------------|------------|
| Normal gameplay | 50 | 100 | 60 |
| Boss fight | 10 | 300 | 55 |
| Stress test | 200 | 500 | 45 |

---

## Optimizations

### Resolution Scaling

For performance-critical moments:

```gdscript
func _apply_deck_settings() -> void:
    if is_steam_deck:
        # Use native Deck resolution
        DisplayServer.window_set_size(Vector2i(1280, 800))

        # Enable dynamic resolution if needed
        if _should_scale_resolution():
            RenderingServer.viewport_set_scaling_3d_mode(
                get_viewport().get_viewport_rid(),
                RenderingServer.VIEWPORT_SCALING_3D_MODE_FSR
            )
```

### Graphics Settings

Recommended Deck presets:

| Setting | Value | Impact |
|---------|-------|--------|
| Shadows | Low | +15% FPS |
| Particles | Medium | +5% FPS |
| Post-processing | Minimal | +8% FPS |
| V-Sync | On | Prevent tearing |

### Battery Conservation

```gdscript
func _set_battery_mode(enabled: bool) -> void:
    if enabled:
        # Cap at 40Hz for battery
        Engine.max_fps = 40
        # Reduce particle count
        ParticleSystem.set_quality_multiplier(0.5)
    else:
        Engine.max_fps = 60
        ParticleSystem.set_quality_multiplier(1.0)
```

---

## Control Mapping

### Default Deck Controls

| Action | Button | Notes |
|--------|--------|-------|
| Move | Left Stick | |
| Aim | Right Stick | |
| Attack | R1 | Tongue attack |
| Bullet Time | L1 | Slow motion |
| Jump | A | |
| Interact | X | |
| Pause | Menu | Start button |
| Board Zoom | D-pad Up/Down | |

### Touchscreen Support

The Deck's touchscreen can be used for the conspiracy board:

```gdscript
func _input(event: InputEvent) -> void:
    if event is InputEventScreenTouch:
        _handle_touch_input(event)
    elif event is InputEventScreenDrag:
        _handle_touch_drag(event)
```

### Trackpads

Enable trackpad for mouse-like precision:

```gdscript
# In Steam Input configuration
# Map right trackpad to mouse movement
# Useful for conspiracy board interaction
```

---

## Verified Checklist

To achieve "Steam Deck Verified" status:

### Input

- [x] Full controller support
- [x] No keyboard required
- [x] Controller glyphs displayed
- [x] Text is legible at 800p

### Display

- [x] Supports 1280x800 default
- [x] No text smaller than 9pt
- [x] UI scales properly
- [x] No external display required

### Seamlessness

- [x] Launches without configuration
- [x] Default controller layout works
- [x] No first-time setup blockers
- [ ] Steam Cloud saves (requires GodotSteam)

### System

- [x] Works offline
- [x] Battery-reasonable gameplay
- [x] No anti-cheat (not applicable)
- [x] Supports sleep/resume

---

## Testing on Deck

### Development Mode

1. Enable Developer Mode in Steam Deck settings
2. Transfer build via SFTP or USB
3. Run from Desktop Mode for debugging
4. Use `console` for GDScript errors

### Performance Profiling

```gdscript
func _ready() -> void:
    if OS.has_environment("STEAM_DECK"):
        Performance.monitor_visible = true
        # Shows FPS, draw calls, memory
```

### Remote Debugging

```bash
# From Deck terminal
godot4 --remote-debug tcp://192.168.1.100:6007 --path /path/to/project
```

---

## UI Considerations

### Text Size

Minimum text sizes for Deck:

| Element | Minimum | Recommended |
|---------|---------|-------------|
| Body text | 14pt | 16pt |
| Button labels | 12pt | 14pt |
| Tooltips | 12pt | 14pt |
| Headings | 18pt | 20pt |

### Button Prompts

Show Deck-appropriate glyphs:

```gdscript
func get_button_glyph(action: String) -> Texture2D:
    match input_manager.get_current_device():
        DeviceType.STEAM_DECK:
            return _deck_glyphs[action]
        DeviceType.GAMEPAD_XBOX:
            return _xbox_glyphs[action]
        DeviceType.GAMEPAD_PS:
            return _playstation_glyphs[action]
        _:
            return _keyboard_glyphs[action]
```

### Safe Zones

Account for Deck's screen bezels:

```gdscript
const DECK_SAFE_MARGIN := 20  # Pixels from edge

func _position_ui_element(element: Control) -> void:
    if is_steam_deck:
        element.position.x = max(element.position.x, DECK_SAFE_MARGIN)
        element.position.y = max(element.position.y, DECK_SAFE_MARGIN)
```

---

## Steam Input Integration

### Controller Configuration

Steam Deck uses Steam Input. Create a default configuration:

1. Launch game in Desktop Mode
2. Open Steam → Controller Configuration
3. Set bindings for all actions
4. Export as "Official" configuration

### Action Sets

Different control schemes for different contexts:

```
Action Sets:
├── Gameplay (default)
│   └── Combat controls
├── ConspiracyBoard
│   └── Touch-friendly navigation
└── Menu
    └── D-pad navigation
```

---

## Common Issues

**Low FPS on Deck**:
- Check particle counts
- Verify resolution is 800p
- Enable FSR scaling
- Reduce shadow quality

**Controls not working**:
- Verify STEAM_DECK detection
- Check Steam Input configuration
- Test in Desktop Mode

**Sleep/resume crash**:
- Ensure `_notification(NOTIFICATION_APPLICATION_RESUMED)` handled
- Restore OpenGL contexts
- Reconnect audio

**Text too small**:
- Use AccessibilityManager text scaling
- Set minimum 14pt for body text
- Test at actual Deck resolution

---

## Summary

| Feature | Status |
|---------|--------|
| Platform detection | Complete |
| Control mapping | Complete |
| Performance optimization | Complete |
| UI scaling | Complete |
| Steam Input | Ready |
| Verified checklist | 90% (pending Cloud) |

The Pond is designed for Deck from the start. The automatic detection and optimization ensure a great handheld experience without user configuration.

---

[← Back to Achievements](achievements.md) | [Next: Controller Support →](controller-support.md)
