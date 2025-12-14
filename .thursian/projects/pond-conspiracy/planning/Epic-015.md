# EPIC-015: Visual Mutation Effects - Development Plan

## Overview

**Epic**: EPIC-015 (Visual Mutation Effects)
**Release Phase**: Alpha
**Priority**: P2 (Polish, not critical)
**Dependencies**: EPIC-006 (Mutation System)
**Estimated Effort**: M (1 week)
**PRD Requirements**: Alpha FR

**Description**: Frog appearance changes based on equipped mutations.

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
- Skip blocked steps and note in DEVELOPERS_MANUAL.md
- Proceed to next story

---

## Stories

### VISUAL-001: frog-sprite-variant-system
**Size**: M | **Priority**: P2

**Acceptance Criteria**:
- [ ] Layered sprite system for frog
- [ ] Base sprite + mutation overlays
- [ ] Dynamic compositing
- [ ] Performance acceptable

**Implementation Approach**:
```gdscript
# Layer order (bottom to top)
# 1. Base frog sprite
# 2. Body modification layer (oil, glow, etc.)
# 3. Accessory layer (extra limbs, eyes, etc.)
# 4. Effect layer (particles, auras)
```

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `max_visual_layers` | int | 4 | Maximum overlay layers |
| `layer_blend_mode` | String | "mix" | How layers combine |

---

### VISUAL-002: oil-trail-visual-black-sludge
**Size**: M | **Priority**: P2

**Acceptance Criteria**:
- [ ] Oil Slick mutation shows trail behind frog
- [ ] Black/dark purple sludge appearance
- [ ] Trail fades over time
- [ ] Matches trail hitbox

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `oil_trail_color` | Color | Color(0.1, 0.05, 0.15, 0.8) | Trail color |
| `oil_trail_width` | float | 24.0 | Trail visual width |
| `oil_trail_fade_time` | float | 2.0 | Fade out duration |
| `oil_drip_particles` | bool | true | Add drip particle effect |

---

### VISUAL-003: toxic-aura-visual-green-glow
**Size**: M | **Priority**: P2

**Acceptance Criteria**:
- [ ] Toxic Aura shows green glow around frog
- [ ] Pulsing animation
- [ ] Matches damage radius
- [ ] Shader-based for performance

**Tunable Parameters**:
| Setting | Type | Default | Description |
|---------|------|---------|-------------|
| `toxic_glow_color` | Color | Color(0.2, 0.9, 0.2, 0.5) | Glow color |
| `toxic_glow_radius` | float | 50.0 | Visual radius |
| `toxic_pulse_speed` | float | 2.0 | Pulse frequency |
| `toxic_pulse_intensity` | float | 0.3 | Pulse variation |

---

### VISUAL-004: mutation-layering-sprite-system
**Size**: L | **Priority**: P2

**Acceptance Criteria**:
- [ ] Multiple mutations show simultaneously
- [ ] Layer order consistent
- [ ] No visual conflicts
- [ ] Handles all 15+ mutations

**Layer Priority**:
| Priority | Category | Mutations |
|----------|----------|-----------|
| 1 (back) | Trails | Oil Slick, Acidic Spit |
| 2 | Auras | Toxic Aura, Radioactive Glow |
| 3 | Body | Tough Skin, Webbed Feet |
| 4 (front) | Effects | Camouflage, Speed lines |

---

### VISUAL-005: mutation-icon-pixel-art
**Size**: M | **Priority**: P2

**Acceptance Criteria**:
- [ ] 16x16 icon for each mutation
- [ ] Clear silhouette
- [ ] Color-coded by type
- [ ] Works at small sizes

**Icon Color Coding**:
| Type | Color Theme |
|------|-------------|
| FROG | Green/blue |
| POLLUTION | Purple/black |
| HYBRID | Orange/yellow |

**Potential Blockers**:
- [ ] Art assets unavailable → Use placeholder colored squares, note in DEVELOPERS_MANUAL.md

---

### VISUAL-006: mutation-preview-ui
**Size**: S | **Priority**: P2

**Acceptance Criteria**:
- [ ] Level-up UI shows visual preview
- [ ] Player can see how they'll look
- [ ] Updates as they hover options

---

## Files to Create

| File | Purpose |
|------|---------|
| `combat/scripts/mutation_visualizer.gd` | Visual management |
| `combat/scenes/MutationVisualLayer.tscn` | Layer component |
| `shared/shaders/toxic_glow.gdshader` | Aura shader |
| `shared/shaders/oil_trail.gdshader` | Trail shader |
| `assets/sprites/mutations/overlays/*.png` | Visual overlays |
| `assets/sprites/mutations/icons/*.png` | UI icons |
| `test/unit/test_mutation_visuals.gd` | Tests |

---

## Shader Reference

**toxic_glow.gdshader**:
```glsl
shader_type canvas_item;

uniform vec4 glow_color : source_color = vec4(0.2, 0.9, 0.2, 0.5);
uniform float radius = 50.0;
uniform float pulse_speed = 2.0;
uniform float pulse_intensity = 0.3;

void fragment() {
    float dist = length(UV - vec2(0.5)) * 2.0;
    float pulse = sin(TIME * pulse_speed) * pulse_intensity + 1.0;
    float alpha = (1.0 - smoothstep(0.0, 1.0, dist)) * glow_color.a * pulse;
    COLOR = vec4(glow_color.rgb, alpha);
}
```

---

## Success Metrics

- 6 stories completed
- Visual effects for all mutations
- Performance maintained at 60fps
- All sprites/icons created (or placeholders)

---

**Plan Status**: Ready for automated execution
**Created**: 2025-12-13
