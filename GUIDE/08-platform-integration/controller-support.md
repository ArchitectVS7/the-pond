# Controller Support

The input system detects controller types automatically and supports full rebinding. This chapter covers the InputManager implementation.

---

## InputManager Structure

**File**: `core/scripts/input_manager.gd`

```gdscript
class_name InputManager
extends Node

enum DeviceType {
    KEYBOARD_MOUSE,
    GAMEPAD_XBOX,
    GAMEPAD_PS,
    GAMEPAD_NINTENDO,
    STEAM_DECK,
    GENERIC_CONTROLLER
}

signal input_device_changed(device_type: DeviceType)
signal control_rebinded(action_name: String)
signal gamepad_connected(device_id: int)
signal gamepad_disconnected(device_id: int)
```

---

## Device Detection

### Automatic Detection

```gdscript
func _detect_gamepad_type(device_id: int) -> void:
    var device_name = Input.get_joy_name(device_id).to_lower()

    if "xbox" in device_name or "xinput" in device_name:
        current_device = DeviceType.GAMEPAD_XBOX
    elif "playstation" in device_name or "dualshock" in device_name or "dualsense" in device_name:
        current_device = DeviceType.GAMEPAD_PS
    elif "nintendo" in device_name or "switch" in device_name:
        current_device = DeviceType.GAMEPAD_NINTENDO
    elif is_steam_deck:
        current_device = DeviceType.STEAM_DECK
    else:
        current_device = DeviceType.GENERIC_CONTROLLER

    input_device_changed.emit(current_device)
```

### Connection Handling

```gdscript
func _on_joy_connection_changed(device_id: int, connected: bool) -> void:
    if connected:
        _detect_gamepad_type(device_id)
        gamepad_connected.emit(device_id)
    else:
        if device_id == last_gamepad_id:
            current_device = DeviceType.KEYBOARD_MOUSE
            input_device_changed.emit(current_device)
        gamepad_disconnected.emit(device_id)
```

---

## Action Bindings

### Binding Structure

```gdscript
class ActionBinding:
    var action_name: String
    var keyboard_key: int = -1
    var mouse_button: int = -1
    var gamepad_button: int = -1
    var gamepad_axis: int = -1
    var gamepad_axis_value: float = 0.0
```

### Default Bindings

```gdscript
func _setup_default_bindings() -> void:
    # Movement
    default_bindings["move_forward"] = _create_binding("move_forward",
        KEY_W, -1, JOY_BUTTON_INVALID, JOY_AXIS_LEFT_Y, -1.0)
    default_bindings["move_backward"] = _create_binding("move_backward",
        KEY_S, -1, JOY_BUTTON_INVALID, JOY_AXIS_LEFT_Y, 1.0)
    default_bindings["move_left"] = _create_binding("move_left",
        KEY_A, -1, JOY_BUTTON_INVALID, JOY_AXIS_LEFT_X, -1.0)
    default_bindings["move_right"] = _create_binding("move_right",
        KEY_D, -1, JOY_BUTTON_INVALID, JOY_AXIS_LEFT_X, 1.0)

    # Combat
    default_bindings["fire"] = _create_binding("fire",
        KEY_NONE, MOUSE_BUTTON_LEFT, JOY_BUTTON_RIGHT_SHOULDER, -1, 0.0)
    default_bindings["aim"] = _create_binding("aim",
        KEY_NONE, MOUSE_BUTTON_RIGHT, JOY_BUTTON_LEFT_SHOULDER, -1, 0.0)
    default_bindings["bullet_time"] = _create_binding("bullet_time",
        KEY_Q, -1, JOY_BUTTON_LEFT_STICK, -1, 0.0)

    # UI
    default_bindings["pause"] = _create_binding("pause",
        KEY_ESCAPE, -1, JOY_BUTTON_START, -1, 0.0)
```

---

## Complete Action Map

| Action | Keyboard | Mouse | Xbox | PlayStation |
|--------|----------|-------|------|-------------|
| move_forward | W | - | LS Up | LS Up |
| move_backward | S | - | LS Down | LS Down |
| move_left | A | - | LS Left | LS Left |
| move_right | D | - | LS Right | LS Right |
| fire | - | LMB | RB | R1 |
| aim | - | RMB | LB | L1 |
| bullet_time | Q | - | LS Click | L3 |
| jump | Space | - | A | Cross |
| crouch | Ctrl | - | B | Circle |
| interact | E | - | X | Square |
| pause | Escape | - | Start | Options |
| inventory | Tab | - | Back | Touchpad |
| board_zoom_in | = | - | D-Up | D-Up |
| board_zoom_out | - | - | D-Down | D-Down |

---

## Rebinding System

### Rebind Action

```gdscript
func rebind_action(action_name: String, event: InputEvent) -> bool:
    if not action_bindings.has(action_name):
        return false

    var binding: ActionBinding = action_bindings[action_name]

    if event is InputEventKey:
        binding.keyboard_key = event.keycode
    elif event is InputEventMouseButton:
        binding.mouse_button = event.button_index
    elif event is InputEventJoypadButton:
        binding.gamepad_button = event.button_index
    elif event is InputEventJoypadMotion:
        binding.gamepad_axis = event.axis
        binding.gamepad_axis_value = sign(event.axis_value)
    else:
        return false

    _save_bindings()
    control_rebinded.emit(action_name)
    return true
```

### Rebinding UI Flow

1. Player selects action to rebind
2. UI shows "Press any key/button..."
3. Capture next InputEvent
4. Call `rebind_action(action, event)`
5. Display new binding

```gdscript
func _on_rebind_button_pressed(action: String) -> void:
    _awaiting_rebind = action
    $RebindPrompt.visible = true
    $RebindPrompt.text = "Press any key or button..."

func _input(event: InputEvent) -> void:
    if _awaiting_rebind.is_empty():
        return

    if _is_valid_rebind_event(event):
        input_manager.rebind_action(_awaiting_rebind, event)
        _awaiting_rebind = ""
        $RebindPrompt.visible = false
        _update_binding_display()
```

---

## Persistence

### Save Bindings

```gdscript
func _save_bindings() -> void:
    var data = {}

    for action_name in action_bindings.keys():
        var binding: ActionBinding = action_bindings[action_name]
        data[action_name] = {
            "keyboard_key": binding.keyboard_key,
            "mouse_button": binding.mouse_button,
            "gamepad_button": binding.gamepad_button,
            "gamepad_axis": binding.gamepad_axis,
            "gamepad_axis_value": binding.gamepad_axis_value
        }

    var file = FileAccess.open(save_file_path, FileAccess.WRITE)
    file.store_string(JSON.stringify(data, "\t"))
    file.close()
```

### Load Bindings

```gdscript
func _load_bindings() -> void:
    if not FileAccess.file_exists(save_file_path):
        return

    var file = FileAccess.open(save_file_path, FileAccess.READ)
    var json = JSON.new()
    json.parse(file.get_as_text())
    file.close()

    var data = json.data
    for action_name in data.keys():
        if action_bindings.has(action_name):
            var saved = data[action_name]
            var binding = action_bindings[action_name]
            binding.keyboard_key = saved.get("keyboard_key", -1)
            binding.mouse_button = saved.get("mouse_button", -1)
            binding.gamepad_button = saved.get("gamepad_button", -1)
            binding.gamepad_axis = saved.get("gamepad_axis", -1)
            binding.gamepad_axis_value = saved.get("gamepad_axis_value", 0.0)
```

---

## Reset Functions

```gdscript
func reset_binding(action_name: String) -> void:
    if not default_bindings.has(action_name):
        return

    action_bindings[action_name] = default_bindings[action_name].duplicate()
    _save_bindings()
    control_rebinded.emit(action_name)

func reset_all_bindings() -> void:
    action_bindings = default_bindings.duplicate(true)
    _save_bindings()
```

---

## Input Latency Monitoring

**File**: `shared/scripts/input_latency_monitor.gd`

PRD requirement: <16ms input lag.

```gdscript
@export var target_latency_ms: float = 16.67  # 1 frame at 60fps

func record_input(action: String) -> void:
    _pending_inputs[action] = Time.get_ticks_usec()

func record_response(action: String) -> void:
    if not _pending_inputs.has(action):
        return

    var latency_us := Time.get_ticks_usec() - _pending_inputs[action]
    var latency_ms := latency_us / 1000.0

    _pending_inputs.erase(action)
    _record_latency(action, latency_ms)
```

### Latency Report

```gdscript
func generate_report() -> String:
    var lines: Array[String] = []
    lines.append("=== INPUT LATENCY REPORT ===")
    lines.append("Target: <%.2f ms" % target_latency_ms)

    for action in get_tracked_actions():
        var avg := get_average_latency_ms(action)
        var status := "PASS" if avg <= target_latency_ms else "FAIL"
        lines.append("  %s: %.2f ms [%s]" % [action, avg, status])

    return "\n".join(lines)
```

---

## Button Glyphs

Display appropriate icons for current device:

```gdscript
func get_glyph_for_action(action: String) -> Texture2D:
    var binding := input_manager.get_binding(action)

    match input_manager.get_current_device():
        DeviceType.KEYBOARD_MOUSE:
            return _get_keyboard_glyph(binding.keyboard_key)
        DeviceType.GAMEPAD_XBOX, DeviceType.STEAM_DECK:
            return _get_xbox_glyph(binding.gamepad_button)
        DeviceType.GAMEPAD_PS:
            return _get_playstation_glyph(binding.gamepad_button)
        DeviceType.GAMEPAD_NINTENDO:
            return _get_nintendo_glyph(binding.gamepad_button)
        _:
            return _get_generic_glyph(binding.gamepad_button)
```

---

## Device Name Display

```gdscript
func get_device_name() -> String:
    match current_device:
        DeviceType.KEYBOARD_MOUSE:
            return "Keyboard & Mouse"
        DeviceType.GAMEPAD_XBOX:
            return "Xbox Controller"
        DeviceType.GAMEPAD_PS:
            return "PlayStation Controller"
        DeviceType.GAMEPAD_NINTENDO:
            return "Nintendo Controller"
        DeviceType.STEAM_DECK:
            return "Steam Deck"
        DeviceType.GENERIC_CONTROLLER:
            return "Generic Controller"
        _:
            return "Unknown"
```

---

## Story Traceability

| Story | Description | Status |
|-------|-------------|--------|
| PLATFORM-008 | Steam Deck Control Mapping | Complete |
| PLATFORM-009 | XInput Controller Support | Complete |
| PLATFORM-010 | Rebindable Controls | Complete |
| COMBAT-013 | Input lag <16ms validation | Complete |

---

## Summary

| Feature | Implementation |
|---------|----------------|
| Device detection | Automatic via device name |
| Controller types | Xbox, PlayStation, Nintendo, Steam Deck |
| Rebinding | Full support, persisted |
| Latency monitoring | <16ms target |
| Button glyphs | Device-appropriate icons |

The input system handles all common controllers without configuration. Players can rebind any action, and the game saves preferences across sessions.

---

[← Back to Steam Deck](steam-deck.md) | [Back to Overview](overview.md)
