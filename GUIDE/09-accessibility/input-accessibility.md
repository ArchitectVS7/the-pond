# Input Accessibility

Input accessibility covers screen shake control and keyboard navigation. These features help players with motion sensitivity and those who can't use a mouse.

---

## Screen Shake Toggle

Screen shake provides feedback but can cause discomfort for some players.

### Setting

```gdscript
var screen_shake_enabled: bool = true

func set_screen_shake_enabled(enabled: bool) -> void:
    screen_shake_enabled = enabled
    save_settings()
    accessibility_setting_changed.emit("screen_shake", enabled)
```

### Integration with Camera

```gdscript
# In camera controller
func add_trauma(amount: float) -> void:
    if not accessibility_manager.screen_shake_enabled:
        return  # Skip shake entirely

    trauma = min(trauma + amount, 1.0)
```

### When Shake is Triggered

| Event | Intensity | Skippable |
|-------|-----------|-----------|
| Player hit | 0.3 | Yes |
| Enemy death | 0.1 | Yes |
| Explosion | 0.5 | Yes |
| Boss attack | 0.4 | Yes |
| Critical hit | 0.2 | Yes |

All shake sources check `screen_shake_enabled` before applying.

---

## Keyboard Navigation

Full keyboard navigation allows playing without a mouse.

### Setting

```gdscript
var keyboard_navigation_enabled: bool = true

func set_keyboard_navigation_enabled(enabled: bool) -> void:
    keyboard_navigation_enabled = enabled
    save_settings()
    accessibility_setting_changed.emit("keyboard_navigation", enabled)
```

### Focus Management

When enabled, the game maintains proper focus chain:

```gdscript
func _ready() -> void:
    if accessibility_manager.keyboard_navigation_enabled:
        # Set initial focus to first button
        $MainMenu/PlayButton.grab_focus()

func _on_menu_opened() -> void:
    if accessibility_manager.keyboard_navigation_enabled:
        $FirstButton.grab_focus()
```

### Focus Navigation Keys

| Key | Action |
|-----|--------|
| Tab | Next focusable |
| Shift+Tab | Previous focusable |
| Arrow keys | Directional navigation |
| Enter/Space | Activate focused element |
| Escape | Cancel/back |

### Setting Up Focus Chain

```gdscript
# In scene setup
$PlayButton.focus_neighbor_bottom = $OptionsButton.get_path()
$PlayButton.focus_neighbor_top = $QuitButton.get_path()

$OptionsButton.focus_neighbor_bottom = $QuitButton.get_path()
$OptionsButton.focus_neighbor_top = $PlayButton.get_path()

$QuitButton.focus_neighbor_bottom = $PlayButton.get_path()
$QuitButton.focus_neighbor_top = $OptionsButton.get_path()
```

### Visual Focus Indicator

Focused elements need visible highlighting:

```gdscript
# In theme or StyleBox
[Button]
focus = StyleBoxFlat
focus.bg_color = Color(0.3, 0.5, 0.8, 0.5)
focus.border_width_all = 2
focus.border_color = Color(0.5, 0.7, 1.0)
```

---

## Conspiracy Board Keyboard Navigation

The conspiracy board supports keyboard-only interaction:

### Navigation

| Key | Action |
|-----|--------|
| Arrow keys | Move selection between cards |
| Enter | Select/interact with card |
| Space | Start/confirm connection |
| Tab | Cycle through cards |
| Escape | Cancel connection |

### Implementation

```gdscript
func _input(event: InputEvent) -> void:
    if not accessibility_manager.keyboard_navigation_enabled:
        return

    if event.is_action_pressed("ui_right"):
        _select_next_card(Vector2.RIGHT)
    elif event.is_action_pressed("ui_left"):
        _select_next_card(Vector2.LEFT)
    elif event.is_action_pressed("ui_up"):
        _select_next_card(Vector2.UP)
    elif event.is_action_pressed("ui_down"):
        _select_next_card(Vector2.DOWN)
    elif event.is_action_pressed("ui_accept"):
        _interact_with_selected()
```

---

## One-Handed Mode (Future)

Planned for Alpha:

| Feature | Implementation |
|---------|----------------|
| Single-stick mode | All actions on one stick + shoulder buttons |
| Auto-aim | Lock onto nearest enemy |
| Simplified controls | Reduce required simultaneous inputs |

---

## Settings Persistence

All input accessibility settings save to the config file:

```gdscript
func save_settings() -> void:
    var config = ConfigFile.new()
    # ... other settings ...
    config.set_value("accessibility", "screen_shake_enabled", screen_shake_enabled)
    config.set_value("accessibility", "keyboard_navigation_enabled", keyboard_navigation_enabled)
    config.save("user://accessibility_settings.cfg")

func load_settings() -> void:
    var config = ConfigFile.new()
    var err = config.load("user://accessibility_settings.cfg")
    if err != OK:
        return

    screen_shake_enabled = config.get_value("accessibility", "screen_shake_enabled", true)
    keyboard_navigation_enabled = config.get_value("accessibility", "keyboard_navigation_enabled", true)
```

---

## Settings Menu UI

```gdscript
func _populate_input_settings() -> void:
    $ScreenShakeToggle.button_pressed = accessibility_manager.screen_shake_enabled
    $KeyboardNavToggle.button_pressed = accessibility_manager.keyboard_navigation_enabled

func _on_screen_shake_toggled(enabled: bool) -> void:
    accessibility_manager.set_screen_shake_enabled(enabled)

func _on_keyboard_nav_toggled(enabled: bool) -> void:
    accessibility_manager.set_keyboard_navigation_enabled(enabled)
```

---

## Testing Checklist

### Screen Shake

- [ ] Disable screen shake in settings
- [ ] Take damage - no camera movement
- [ ] Kill enemies - no camera movement
- [ ] Boss attacks - no camera movement
- [ ] Re-enable - shake returns

### Keyboard Navigation

- [ ] Navigate main menu with Tab/arrows
- [ ] All buttons are reachable
- [ ] Focus indicator is visible
- [ ] Enter/Space activates buttons
- [ ] Escape backs out of menus
- [ ] Conspiracy board navigable with keyboard

---

## Future Accessibility Features

| Feature | Phase | Description |
|---------|-------|-------------|
| Auto-aim | Alpha | Assist for aiming |
| Subtitles | Alpha | For dialogue/informants |
| Audio cues | Alpha | Sound for visual events |
| One-handed mode | Beta | Single controller support |
| Difficulty modifiers | Beta | Invincibility, slow-mo, etc. |

---

## Summary

| Feature | Default | Configurable |
|---------|---------|--------------|
| Screen shake | Enabled | Yes |
| Keyboard navigation | Enabled | Yes |
| Focus indicators | Always on | Theme-based |
| One-handed mode | Not yet | Planned |

Input accessibility ensures The Pond can be played by people with various physical needs. The toggle-based approach lets players choose what works for them.

---

[← Back to Text Scaling](text-scaling.md) | [Back to Overview](overview.md)
