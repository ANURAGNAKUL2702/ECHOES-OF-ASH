# Cinematic Camera 2D - Quick Reference

## Quick Setup

### 1. Add Camera to Scene
```
1. Select your Player node (or target node)
2. Add Child Node → Camera2D
3. Attach script: res://scripts/cinematic_camera_2d.gd
4. Enable camera: Check "Current" in Inspector
```

### 2. Basic Configuration
```gdscript
# In Inspector, adjust these key settings:
- smooth_follow: true
- damping_speed_x: 5.0
- damping_speed_y: 5.0
- base_zoom: Vector2(1.5, 1.5)
- default_shake_intensity: 10.0
```

## Essential API

### Trigger Screen Shake
```gdscript
# Using default values
camera.shake()

# Custom intensity and duration
camera.shake(15.0, 0.5)  # 15 pixels for 0.5 seconds
```

### Control Zoom
```gdscript
# Set specific zoom
camera.set_zoom(Vector2(2.0, 2.0))

# Zoom in/out gradually
camera.zoom_in(0.3)
camera.zoom_out(0.3)

# Reset to base zoom
camera.reset_zoom()

# Instant zoom (no smoothing)
camera.set_zoom(Vector2(1.0, 1.0), true)
```

### Change Target
```gdscript
# Follow a different node
camera.set_follow_target(boss_node)

# Return to following parent
camera.set_follow_target(null)
```

### Enable/Disable Features
```gdscript
# Toggle smooth follow
camera.enable_smooth_follow(false)

# Configure dead-zone
camera.set_dead_zone(true, 150.0, 100.0)

# Change damping speed
camera.set_damping_speed(8.0)
```

## Common Use Cases

### Impact/Damage Shake
```gdscript
func _on_player_hit(damage: float) -> void:
    var intensity = clamp(damage * 2.0, 5.0, 30.0)
    camera.shake(intensity, 0.3)
```

### Combat Zoom
```gdscript
func _on_enter_combat() -> void:
    camera.set_zoom(Vector2(2.0, 2.0))

func _on_exit_combat() -> void:
    camera.reset_zoom()
```

### Boss Focus
```gdscript
func introduce_boss(boss: Node2D) -> void:
    camera.set_follow_target(boss)
    camera.shake(20.0, 1.0)
    await get_tree().create_timer(3.0).timeout
    camera.set_follow_target(player)
```

## Signals

```gdscript
# Connect to camera events
camera.shake_started.connect(_on_shake_start)
camera.shake_ended.connect(_on_shake_end)
camera.zoom_changed.connect(_on_zoom_change)

func _on_shake_start(intensity: float, duration: float):
    print("Shake: ", intensity, " for ", duration, "s")

func _on_zoom_change(new_zoom: Vector2):
    print("Zoom: ", new_zoom)
```

## Query Methods

```gdscript
# Check camera state
if camera.is_shaking():
    print("Currently shaking")

var current_zoom = camera.get_current_zoom()
var target_zoom = camera.get_target_zoom()
var target_node = camera.get_follow_target()
var shake_power = camera.get_shake_intensity()
```

## Configuration Tips

### Smooth Platformer Camera
```gdscript
camera.smooth_follow = true
camera.damping_speed_x = 3.0
camera.damping_speed_y = 4.0
camera.set_dead_zone(true, 120.0, 80.0)
camera.base_zoom = Vector2(1.5, 1.5)
```

### Responsive Action Camera
```gdscript
camera.smooth_follow = true
camera.damping_speed_x = 8.0
camera.damping_speed_y = 8.0
camera.enable_dead_zone = false
camera.base_zoom = Vector2(2.0, 2.0)
```

### Cutscene Camera
```gdscript
camera.smooth_follow = false  # Direct control
camera.smooth_zoom = true
camera.zoom_speed = 2.0
```

## Parameter Ranges

| Parameter | Min | Max | Default | Description |
|-----------|-----|-----|---------|-------------|
| damping_speed_x/y | 0.1 | 20.0 | 5.0 | Follow smoothness |
| dead_zone_width | 0.0 | 500.0 | 100.0 | Dead-zone width |
| dead_zone_height | 0.0 | 500.0 | 80.0 | Dead-zone height |
| zoom_speed | 0.1 | 10.0 | 3.0 | Zoom transition speed |
| default_shake_intensity | 0.0 | 50.0 | 10.0 | Shake strength (pixels) |
| default_shake_duration | 0.0 | 2.0 | 0.3 | Shake length (seconds) |
| shake_decay | 0.0 | 10.0 | 5.0 | Shake fade rate |
| shake_frequency | 0.0 | 50.0 | 15.0 | Shake oscillation speed |

## Testing Scene

Run `scenes/camera_test.tscn` to test all features:

**Controls:**
- Q - Trigger shake
- E - Zoom in
- R - Zoom out
- T/Insert - Reset zoom
- F - Toggle smooth follow
- G - Toggle dead zone

## Troubleshooting

**Camera not following target:**
- Check that follow_target is set or parent exists
- Verify smooth_follow settings
- Ensure camera is enabled (Current = true)

**Shake not visible:**
- Increase default_shake_intensity
- Check shake_frequency is not 0
- Verify shake() is being called

**Zoom not smooth:**
- Enable smooth_zoom = true
- Adjust zoom_speed (higher = faster)
- Check min/max zoom constraints

**Camera too slow/fast:**
- Adjust damping_speed_x and damping_speed_y
- Lower values = slower/smoother
- Higher values = faster/snappier

## Additional Resources

- Full documentation: `CAMERA_IMPLEMENTATION_SUMMARY.md`
- Testing guide: `TEST_CAMERA.md`
- Script: `scripts/cinematic_camera_2d.gd`
- Test scene: `scenes/camera_test.tscn`
