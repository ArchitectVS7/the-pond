# EPIC-011: Accessibility Features - Development Plan

## Overview

**Epic**: EPIC-011 (Accessibility Features)
**Release Phase**: MVP
**Priority**: P0 (WCAG compliance required)
**Dependencies**: EPIC-003, EPIC-001 (Conspiracy Board, Combat)
**Estimated Effort**: M (1 week)
**PRD Requirements**: NFR-002, CI-3.2

**Description**: 3 colorblind modes, text scaling, screen shake toggle, keyboard navigation.

---

## Automated Workflow Protocol

### Before Each Story
1. **READ THIS PLAN** for re-alignment before starting
2. Verify dependencies from previous stories are complete
3. Check DEVELOPERS_MANUAL.md for any tunable parameters from prior work

### Story Completion Criteria
- All tests pass (adversarial workflow complete)
- Tunable parameters documented in DEVELOPERS_MANUAL.md
- No human sign-off required - proceed immediately to next story

### Blocker Handling
- If a story cannot be completed due to blockers or human-required actions:
  - **SKIP** the blocked steps
  - **NOTE** in DEVELOPERS_MANUAL.md under "Blocked Steps" section
  - **PROCEED** to next story

---

## Stories

### ACCESS-001: colorblind-mode-deuteranopia-shader
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Deuteranopia (red-green) shader created
- [ ] Applied as post-process effect
- [ ] Toggleable in settings
- [ ] Corrects game palette for visibility

**Shader Implementation**:
```gdscript
# Color transformation matrix for deuteranopia
const DEUTAN_MATRIX = [
    0.625, 0.375, 0.0,
    0.7, 0.3, 0.0,
    0.0, 0.3, 0.7
]
```

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `colorblind_mode` | int | 0 | 0=off, 1=deutan, 2=protan, 3=tritan |
| `colorblind_strength` | float | 1.0 | Filter intensity (0-1) |

---

### ACCESS-002: colorblind-mode-protanopia-shader
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Protanopia (red-blind) shader created
- [ ] Distinct from deuteranopia
- [ ] Same toggle system

**Shader Implementation**:
```gdscript
# Color transformation matrix for protanopia
const PROTAN_MATRIX = [
    0.567, 0.433, 0.0,
    0.558, 0.442, 0.0,
    0.0, 0.242, 0.758
]
```

---

### ACCESS-003: colorblind-mode-tritanopia-shader
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] Tritanopia (blue-yellow) shader created
- [ ] Distinct from other modes
- [ ] Same toggle system

**Shader Implementation**:
```gdscript
# Color transformation matrix for tritanopia
const TRITAN_MATRIX = [
    0.95, 0.05, 0.0,
    0.0, 0.433, 0.567,
    0.0, 0.475, 0.525
]
```

---

### ACCESS-004: text-scaling-3sizes-08-10-13
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] 3 text size options (Small, Normal, Large)
- [ ] Scale factors: 0.8x, 1.0x, 1.3x
- [ ] Applies to all UI text
- [ ] Layout adjusts appropriately

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `text_scale_small` | float | 0.8 | Small text multiplier |
| `text_scale_normal` | float | 1.0 | Normal text multiplier |
| `text_scale_large` | float | 1.3 | Large text multiplier |
| `current_text_scale` | int | 1 | 0=small, 1=normal, 2=large |

---

### ACCESS-005: screen-shake-toggle-setting
**Size**: S | **Priority**: P0

**Acceptance Criteria**:
- [ ] Screen shake can be disabled
- [ ] Toggle in accessibility settings
- [ ] Setting persists
- [ ] Affects all shake sources

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `screen_shake_enabled` | bool | true | Master shake toggle |
| `reduced_shake_intensity` | float | 0.3 | Optional reduced mode |

---

### ACCESS-006: keyboard-navigation-all-menus
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] All menus navigable with keyboard
- [ ] Tab/Shift+Tab cycles elements
- [ ] Arrow keys for directional navigation
- [ ] Enter/Space to activate
- [ ] Escape to go back

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `keyboard_nav_enabled` | bool | true | Enable keyboard navigation |
| `focus_wrap` | bool | true | Wrap focus at list ends |

---

### ACCESS-007: wcag-aa-contrast-validation
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] All text meets 4.5:1 contrast ratio
- [ ] Important UI elements meet 3:1
- [ ] Validation tool/report created
- [ ] Non-compliant elements fixed

**WCAG AA Requirements**:
- Normal text: 4.5:1 minimum
- Large text (18pt+): 3:1 minimum
- UI components: 3:1 minimum

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `high_contrast_mode` | bool | false | Enhanced contrast option |

---

### ACCESS-008: settings-menu-accessibility-tab
**Size**: S | **Priority**: P0

**Acceptance Criteria**:
- [ ] Dedicated accessibility tab in settings
- [ ] Groups all accessibility options
- [ ] Clear descriptions for each option
- [ ] Preview where applicable

**Settings Organization**:
```
Accessibility
├── Colorblind Mode: [Off | Deuteranopia | Protanopia | Tritanopia]
├── Text Size: [Small | Normal | Large]
├── Screen Shake: [On | Off | Reduced]
├── High Contrast: [On | Off]
└── Keyboard Navigation: [On | Off]
```

---

### ACCESS-009: control-rebinding-ui
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] All controls rebindable
- [ ] Shows current binding
- [ ] Conflict detection
- [ ] Reset to defaults

*Note: Shared with PLATFORM-010, may be combined*

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `rebind_timeout` | float | 5.0 | Cancel rebind after seconds |
| `allow_duplicate_bindings` | bool | false | Allow same key for multiple actions |

---

### ACCESS-010: accessibility-testing-validation
**Size**: M | **Priority**: P0

**Acceptance Criteria**:
- [ ] All accessibility features tested
- [ ] Colorblind modes validated
- [ ] Keyboard navigation complete
- [ ] Screen reader basics work

**Testing Checklist**:
- [ ] Can complete game with colorblind mode
- [ ] Can navigate all menus via keyboard
- [ ] Can read all text at each size
- [ ] Can play with screen shake disabled
- [ ] UI elements have accessible names

**Potential Blockers**:
- [ ] Screen reader testing requires external tools → Note limitations in DEVELOPERS_MANUAL.md

---

## Files to Create

| File | Purpose |
|------|---------|
| `shared/shaders/colorblind_filter.gdshader` | Colorblind shader |
| `shared/scripts/accessibility_manager.gd` | Accessibility settings |
| `shared/scripts/text_scaler.gd` | Text scaling system |
| `metagame/scenes/AccessibilitySettings.tscn` | Settings UI |
| `test/unit/test_accessibility.gd` | Accessibility tests |

---

## Shader Reference

**colorblind_filter.gdshader**:
```glsl
shader_type canvas_item;

uniform int mode : hint_range(0, 3) = 0;
uniform float strength : hint_range(0.0, 1.0) = 1.0;

// Transformation matrices for each type
const mat3 DEUTAN = mat3(
    vec3(0.625, 0.375, 0.0),
    vec3(0.7, 0.3, 0.0),
    vec3(0.0, 0.3, 0.7)
);
const mat3 PROTAN = mat3(
    vec3(0.567, 0.433, 0.0),
    vec3(0.558, 0.442, 0.0),
    vec3(0.0, 0.242, 0.758)
);
const mat3 TRITAN = mat3(
    vec3(0.95, 0.05, 0.0),
    vec3(0.0, 0.433, 0.567),
    vec3(0.0, 0.475, 0.525)
);

void fragment() {
    vec4 color = texture(TEXTURE, UV);
    vec3 rgb = color.rgb;

    mat3 transform = mat3(vec3(1,0,0), vec3(0,1,0), vec3(0,0,1));
    if (mode == 1) transform = DEUTAN;
    else if (mode == 2) transform = PROTAN;
    else if (mode == 3) transform = TRITAN;

    vec3 corrected = transform * rgb;
    COLOR = vec4(mix(rgb, corrected, strength), color.a);
}
```

---

## Success Metrics

- 10 stories completed
- WCAG AA compliance achieved
- All 3 colorblind modes working
- Full keyboard navigation
- Settings persistent and functional

---

**Plan Status**: Ready for automated execution
**Created**: 2025-12-13
