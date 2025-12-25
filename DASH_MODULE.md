# Dash Module Documentation

## Overview

The `DashModule` is a standalone, production-ready dash system for 2D action games in Godot 4. It provides a complete dash mechanic with cooldown management, invincibility frames, and progression-based unlocking.

## Features

### Core Dash Mechanics
- **Horizontal Burst Movement**: Short, fast dash in horizontal direction
- **Configurable Speed**: Adjust dash velocity to match your game's feel
- **Configurable Duration**: Control how long the dash lasts
- **Direction Control**: Auto-detect from player movement or specify manually
- **Direction Lock**: Optional locking of direction during dash

### Cooldown System
- **Cooldown Timer**: Prevents spam dashing with configurable cooldown period
- **Cooldown Progress**: Query cooldown state with `get_cooldown_progress()`
- **Cooldown Ready Signal**: Get notified when dash is available again

### Invincibility Frames (i-frames)
- **Temporary Invincibility**: Player is invincible during dash
- **Configurable Duration**: Set i-frame duration independently from dash duration
- **Query Method**: Check invincibility state with `is_invincible()`

### Progression Support
- **Enable/Disable Toggle**: Lock or unlock dash for game progression
- **Runtime Control**: Change enabled state at any time with `set_enabled(bool)`

### Design Philosophy
- **Separation of Concerns**: Module does NOT read input directly
- **No Dependencies**: Completely standalone, no coupling to combat, camera, or other systems
- **Signal-Based Communication**: React to dash events with signals
- **Clean API**: Simple, intuitive method calls

## Installation

1. Copy `dash_module.gd` to your project's scripts folder
2. Add a `DashModule` node to your player scene or game manager
3. Configure parameters in the Godot inspector
4. Integrate with your input handling system

## Usage

### Basic Integration

```gdscript
# In your player controller or input handler
extends CharacterBody2D

@export var dash_module: DashModule

func _ready():
    # Connect to dash signals for feedback
    dash_module.dash_started.connect(_on_dash_started)
    dash_module.dash_ended.connect(_on_dash_ended)
    dash_module.dash_ready.connect(_on_dash_ready)

func _process(_delta):
    # Handle dash input
    if Input.is_action_just_pressed("dash"):
        attempt_dash()

func attempt_dash():
    # Check if dash is available
    if not dash_module.can_dash():
        return
    
    # Get direction (auto-detect from velocity or use input)
    var direction = sign(velocity.x) if velocity.x != 0 else 1.0
    
    # Execute dash
    dash_module.dash(self, direction)

func _on_dash_started():
    # Play dash sound, spawn particles, etc.
    pass

func _on_dash_ended():
    # Play landing sound, spawn dust, etc.
    pass

func _on_dash_ready():
    # Update UI, play ready sound, etc.
    pass
```

### Checking Invincibility

```gdscript
# In your damage/collision handling code
func take_damage(amount: int):
    # Check if player is invincible from dash
    if dash_module.is_invincible():
        return  # Ignore damage during dash i-frames
    
    # Apply damage...
```

### Progression-Based Unlocking

```gdscript
# When player acquires dash ability
func unlock_dash_ability():
    dash_module.set_enabled(true)
    # Show unlock notification, update UI, etc.

# Temporarily disable dash (e.g., in cutscene)
func disable_dash():
    dash_module.set_enabled(false)
```

### Querying Cooldown State

```gdscript
# Update UI cooldown indicator
func _process(_delta):
    var cooldown_progress = dash_module.get_cooldown_progress()
    $DashCooldownBar.value = 1.0 - cooldown_progress
    
    var time_remaining = dash_module.get_time_until_ready()
    $DashCooldownLabel.text = "%.1f" % time_remaining
```

## API Reference

### Properties (Export Variables)

| Property | Type | Default | Description |
|----------|------|---------|-------------|
| `dash_speed` | float | 600.0 | Speed during dash (pixels per second) |
| `dash_duration` | float | 0.2 | Duration of the dash (seconds) |
| `dash_cooldown` | float | 1.0 | Cooldown time between dashes (seconds) |
| `iframe_duration` | float | 0.15 | Duration of invincibility frames (seconds) |
| `enabled` | bool | true | Whether dash ability is unlocked/enabled |
| `lock_direction` | bool | true | If true, locks direction during dash |
| `dash_control` | float | 0.8 | Control influence during dash when not locked (0.0-1.0) |

### Methods

#### `dash(player: CharacterBody2D, direction: float = 0.0) -> bool`
Execute a dash for the given player.

**Parameters:**
- `player`: The CharacterBody2D to apply dash to
- `direction`: Dash direction (-1 left, 1 right, 0 auto-detect from horizontal velocity)

**Returns:**
- `true` if dash was executed, `false` if on cooldown or disabled

**Example:**
```gdscript
var success = dash_module.dash(self, 1.0)  # Dash right
```

#### `can_dash() -> bool`
Check if dash is currently available.

**Returns:**
- `true` if dash can be executed

**Example:**
```gdscript
if dash_module.can_dash():
    # Show "press to dash" prompt
```

#### `is_dashing() -> bool`
Check if a dash is currently in progress.

**Returns:**
- `true` if currently dashing

**Example:**
```gdscript
if dash_module.is_dashing():
    # Disable other actions during dash
```

#### `is_invincible() -> bool`
Check if invincibility frames are currently active.

**Returns:**
- `true` if i-frames are active

**Example:**
```gdscript
if not dash_module.is_invincible():
    apply_damage(damage_amount)
```

#### `get_cooldown_progress() -> float`
Get current cooldown progress.

**Returns:**
- Value from 0.0 (ready) to 1.0 (just used)

**Example:**
```gdscript
var progress = dash_module.get_cooldown_progress()
$CooldownBar.value = 1.0 - progress  # Invert for fill bar
```

#### `get_dash_direction() -> float`
Get the current dash direction.

**Returns:**
- `-1` for left, `1` for right, `0` if not dashing

**Example:**
```gdscript
var dir = dash_module.get_dash_direction()
if dir != 0:
    spawn_dash_particles(dir)
```

#### `set_enabled(value: bool) -> void`
Enable or disable the dash ability.

**Parameters:**
- `value`: true to enable, false to disable

**Example:**
```gdscript
dash_module.set_enabled(true)  # Unlock dash
```

#### `cancel_dash() -> void`
Immediately cancel the current dash.

**Example:**
```gdscript
if player_hit_wall:
    dash_module.cancel_dash()
```

#### `get_time_until_ready() -> float`
Get time remaining until dash is ready again.

**Returns:**
- Time in seconds (0.0 if ready)

**Example:**
```gdscript
var time = dash_module.get_time_until_ready()
print("Dash ready in: %.1f seconds" % time)
```

### Signals

#### `dash_started()`
Emitted when a dash begins.

**Use for:**
- Playing dash sound effects
- Spawning dash particles/effects
- Updating animations
- Screen shake

**Example:**
```gdscript
func _on_dash_started():
    $AudioStreamPlayer.play()
    $DashParticles.emitting = true
```

#### `dash_ended()`
Emitted when a dash ends.

**Use for:**
- Playing landing effects
- Spawning dust particles
- Returning to normal animation
- Re-enabling other actions

**Example:**
```gdscript
func _on_dash_ended():
    $DustParticles.emitting = true
    animation_player.play("idle")
```

#### `dash_ready()`
Emitted when dash comes off cooldown.

**Use for:**
- Playing "ready" sound
- Updating UI indicators
- Visual feedback (flash, glow, etc.)

**Example:**
```gdscript
func _on_dash_ready():
    $ReadySound.play()
    $DashIcon.modulate = Color.WHITE
```

## Configuration Guidelines

### Dash Speed
- **Action Games**: 600-800 pixels/second
- **Platformers**: 400-600 pixels/second
- **Fast-Paced**: 800-1200 pixels/second

### Dash Duration
- **Short Dodge**: 0.1-0.15 seconds
- **Standard Dash**: 0.2-0.3 seconds
- **Long Dash**: 0.3-0.5 seconds

### Cooldown
- **Frequent Dashing**: 0.5-1.0 seconds
- **Strategic Use**: 1.5-3.0 seconds
- **Limited Resource**: 3.0+ seconds

### I-Frame Duration
- **Short Protection**: 0.1-0.15 seconds
- **Standard Protection**: 0.15-0.25 seconds
- **Extended Protection**: 0.25-0.35 seconds

**Tip**: I-frame duration should typically be shorter than or equal to dash duration.

## Advanced Techniques

### Dash Canceling
Allow players to cancel dash into other actions:

```gdscript
func _process(_delta):
    if dash_module.is_dashing():
        if Input.is_action_just_pressed("attack"):
            dash_module.cancel_dash()
            perform_attack()
```

### Directional Dashing
Use input direction instead of movement direction:

```gdscript
func attempt_dash():
    var input_dir = Input.get_axis("move_left", "move_right")
    if input_dir != 0:
        dash_module.dash(self, input_dir)
```

### Dash Combos
Track consecutive dashes for special effects:

```gdscript
var dash_combo_count = 0

func _on_dash_started():
    dash_combo_count += 1
    if dash_combo_count >= 3:
        # Special effect for triple dash
        apply_speed_boost()

func _on_dash_ready():
    # Reset combo after cooldown
    dash_combo_count = 0
```

### Visual Feedback
Create a dash trail effect:

```gdscript
func _on_dash_started():
    var trail = dash_trail_scene.instantiate()
    get_parent().add_child(trail)
    trail.global_position = global_position
    trail.direction = dash_module.get_dash_direction()
```

## Troubleshooting

### Dash Not Working
1. Check that `enabled` is `true`
2. Verify `can_dash()` returns `true`
3. Ensure player reference is valid `CharacterBody2D`
4. Check that cooldown has elapsed

### Dash Too Slow/Fast
- Adjust `dash_speed` property
- Consider player's base speed interaction
- Test with different character sizes

### Direction Issues
- Set `direction` parameter explicitly instead of auto-detect
- Check player's velocity sign
- Use input direction as fallback

### I-Frames Not Working
- Ensure `iframe_duration` is greater than 0
- Check `is_invincible()` in your damage code
- Verify i-frame duration is appropriate for your game

## Best Practices

1. **Always Check Availability**: Use `can_dash()` before calling `dash()`
2. **Provide Feedback**: Connect to signals for audio/visual feedback
3. **Respect I-Frames**: Check `is_invincible()` in all damage code
4. **Test Balance**: Iterate on cooldown and speed values
5. **Clear Communication**: Show cooldown progress to players
6. **Fail Gracefully**: Handle dash failures with appropriate feedback

## Integration with Other Systems

### Animation System
```gdscript
func _on_dash_started():
    animation_player.play("dash")

func _on_dash_ended():
    animation_player.play("idle")
```

### Particle System
```gdscript
func _on_dash_started():
    $DashParticles.emitting = true
    $DashParticles.direction = Vector2(dash_module.get_dash_direction(), 0)
```

### Sound System
```gdscript
func _on_dash_started():
    audio_manager.play_sound("dash_whoosh")

func _on_dash_ended():
    audio_manager.play_sound("dash_land")
```

### UI System
```gdscript
func _process(_delta):
    # Update cooldown display
    ui_manager.update_dash_cooldown(
        dash_module.get_cooldown_progress()
    )
    
    # Show dash availability
    ui_manager.set_dash_available(
        dash_module.can_dash()
    )
```

## License

This module is part of the ECHOES OF ASH project and is open source for educational and commercial use.

## Contributing

Improvements and extensions to the dash module are welcome! Consider adding:
- Vertical dashing support
- Air dash variants
- Dash attack integration
- Stamina/energy cost system
- Multi-directional dashing
