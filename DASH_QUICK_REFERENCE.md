# Dash Module - Quick Reference

## Setup (30 seconds)

1. Add `DashModule` node to your player scene
2. Configure parameters in Inspector (or use defaults)
3. Call `dash_module.dash(self, direction)` from input handler

## Basic Integration

```gdscript
extends CharacterBody2D

@export var dash_module: DashModule

func _process(_delta):
    if Input.is_action_just_pressed("dash") and dash_module.can_dash():
        dash_module.dash(self, sign(velocity.x))
```

## Key Methods

| Method | Purpose |
|--------|---------|
| `dash(player, dir)` | Execute dash |
| `can_dash()` | Check if ready |
| `is_dashing()` | Check if active |
| `is_invincible()` | Check i-frames |
| `set_enabled(bool)` | Lock/unlock |

## Default Parameters

- **Speed**: 600 px/s
- **Duration**: 0.2 seconds
- **Cooldown**: 1.0 second
- **I-Frames**: 0.15 seconds

## Common Use Cases

### Unlock Dash Ability
```gdscript
dash_module.set_enabled(true)
```

### Check Invincibility for Damage
```gdscript
func take_damage(amount):
    if dash_module.is_invincible():
        return
    health -= amount
```

### Display Cooldown UI
```gdscript
$CooldownBar.value = 1.0 - dash_module.get_cooldown_progress()
```

### React to Dash Events
```gdscript
func _ready():
    dash_module.dash_started.connect(_on_dash)
    
func _on_dash():
    $DashSound.play()
    $DashParticles.emitting = true
```

## Documentation

- **Complete API**: See `DASH_MODULE.md`
- **Testing Guide**: See `TEST_DASH_MODULE.md`
- **Example Code**: See `scripts/dash_integration_example.gd`

## Requirements

- Godot 4.2+
- CharacterBody2D player
- "dash" input action (configure in Project Settings)
