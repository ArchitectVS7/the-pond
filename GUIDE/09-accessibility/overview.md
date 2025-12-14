# Accessibility Overview

Accessibility makes The Pond playable by everyone. This chapter covers colorblind modes, text scaling, and input options that meet WCAG AA standards.

---

## What's Here

| File | What It Covers |
|------|----------------|
| [Colorblind Modes](colorblind-modes.md) | Shader-based filters for three types |
| [Text Scaling](text-scaling.md) | Dynamic text size adjustment |
| [Input Accessibility](input-accessibility.md) | Keyboard navigation, screen shake toggle |

---

## System Architecture

**File**: `shared/scripts/accessibility_manager.gd`

```gdscript
class_name AccessibilityManager
extends Node

signal accessibility_setting_changed(setting_name: String, value)
signal text_scale_changed(scale: float)
signal colorblind_mode_changed(mode: int)

enum ColorblindMode {
    NORMAL = 0,
    DEUTERANOPIA = 1,  # Red-green (most common)
    PROTANOPIA = 2,    # Red-blind
    TRITANOPIA = 3     # Blue-yellow
}

enum TextScale {
    SMALL = 0,   # 0.8x
    NORMAL = 1,  # 1.0x
    LARGE = 2    # 1.3x
}
```

---

## Current Features

| Feature | Status | Notes |
|---------|--------|-------|
| Colorblind modes | Complete | 3 modes via shader |
| Text scaling | Complete | 3 sizes |
| Screen shake toggle | Complete | On/off |
| Keyboard navigation | Complete | Full UI support |
| WCAG contrast | Complete | AA validation |

---

## Settings Storage

```gdscript
var colorblind_mode: ColorblindMode = ColorblindMode.NORMAL
var text_scale: TextScale = TextScale.NORMAL
var screen_shake_enabled: bool = true
var keyboard_navigation_enabled: bool = true
```

### Persistence

```gdscript
func save_settings() -> void:
    var config = ConfigFile.new()
    config.set_value("accessibility", "colorblind_mode", colorblind_mode)
    config.set_value("accessibility", "text_scale", text_scale)
    config.set_value("accessibility", "screen_shake_enabled", screen_shake_enabled)
    config.set_value("accessibility", "keyboard_navigation_enabled", keyboard_navigation_enabled)
    config.save("user://accessibility_settings.cfg")
```

---

## WCAG Compliance

### Contrast Requirements

| Element | Ratio | Standard |
|---------|-------|----------|
| Text | 4.5:1 | WCAG AA |
| UI components | 3.0:1 | WCAG AA |
| Large text (18pt+) | 3.0:1 | WCAG AA |

### Validation Function

```gdscript
const WCAG_AA_TEXT_CONTRAST = 4.5
const WCAG_AA_UI_CONTRAST = 3.0

func validate_contrast_ratio(color1: Color, color2: Color, is_text: bool = true) -> bool:
    var luminance1 = calculate_relative_luminance(color1)
    var luminance2 = calculate_relative_luminance(color2)

    var lighter = max(luminance1, luminance2)
    var darker = min(luminance1, luminance2)

    var contrast_ratio = (lighter + 0.05) / (darker + 0.05)
    var required_ratio = WCAG_AA_TEXT_CONTRAST if is_text else WCAG_AA_UI_CONTRAST

    return contrast_ratio >= required_ratio
```

---

## Integration Points

### With UI System

```gdscript
# Apply text scale when UI loads
func _on_scene_loaded() -> void:
    accessibility_manager.apply_all_settings()
```

### With Combat System

```gdscript
# Respect screen shake setting
func screen_shake(intensity: float) -> void:
    if accessibility_manager.screen_shake_enabled:
        camera.add_trauma(intensity)
```

### With Settings Menu

```gdscript
func _on_colorblind_option_changed(index: int) -> void:
    accessibility_manager.set_colorblind_mode(index as AccessibilityManager.ColorblindMode)

func _on_text_scale_option_changed(index: int) -> void:
    accessibility_manager.set_text_scale(index as AccessibilityManager.TextScale)
```

---

## Signals

| Signal | When Emitted |
|--------|--------------|
| `accessibility_setting_changed` | Any setting changes |
| `text_scale_changed` | Text scale updated |
| `colorblind_mode_changed` | Colorblind filter changed |

---

## Story Traceability

| Story | Description | Status |
|-------|-------------|--------|
| ACCESS-001 | Colorblind Mode - Deuteranopia | Complete |
| ACCESS-002 | Colorblind Mode - Protanopia | Complete |
| ACCESS-003 | Colorblind Mode - Tritanopia | Complete |
| ACCESS-004 | Text Scaling System | Complete |
| ACCESS-005 | WCAG AA Contrast Validation | Complete |
| ACCESS-006 | Screen Shake Toggle | Complete |
| ACCESS-007 | Keyboard Navigation | Complete |

---

## Testing Recommendations

### Colorblind Testing

1. Use [Coblis](https://www.color-blindness.com/coblis-color-blindness-simulator/) to simulate colorblindness
2. Test each mode with game screenshots
3. Verify critical information isn't color-dependent

### Text Scale Testing

1. Set to LARGE scale
2. Navigate all menus
3. Verify no text overflow or truncation

### Contrast Testing

1. Use browser devtools or [WebAIM Contrast Checker](https://webaim.org/resources/contrastchecker/)
2. Test all text/background combinations
3. Verify 4.5:1 for body text, 3.0:1 for UI

---

## Next Steps

If you're working on accessibility:

1. Start with [Colorblind Modes](colorblind-modes.md) - shader implementation
2. Review [Text Scaling](text-scaling.md) - dynamic sizing
3. Test [Input Accessibility](input-accessibility.md) - keyboard navigation

---

[Back to Index](../index.md) | [Next: Colorblind Modes](colorblind-modes.md)
