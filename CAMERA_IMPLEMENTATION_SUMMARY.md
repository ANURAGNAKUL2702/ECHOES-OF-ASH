# Cinematic Camera 2D - Implementation Summary

## Overview

The **CinematicCamera2D** is a production-quality camera controller for Godot 4 that provides cinematic camera behaviors including smooth following, screen shake, dynamic zoom, and dead-zone support. It's designed to be reusable, player-independent, and easy to integrate into any 2D game.

## Features

### 1. Smooth Camera Follow
- **Configurable Damping**: Adjustable smooth follow with separate X/Y axis damping speeds
- **Target Flexibility**: Can follow any Node2D or automatically follow parent
- **Independent Axis Control**: Optional separate damping for horizontal and vertical movement
- **Player Independence**: No direct coupling to player movement logic

### 2. Screen Shake
- **Dynamic Shake Effects**: Trigger shake with customizable intensity and duration
- **Smooth Oscillation**: Uses sine/cosine waves for natural-looking shake
- **Automatic Decay**: Shake intensity decreases smoothly over time
- **Configurable Frequency**: Adjust shake speed to match different impact types
- **Signal-Based**: Emits signals when shake starts and ends

### 3. Dynamic Zoom
- **Smooth Transitions**: Interpolated zoom changes for cinematic effect
- **Zoom Control**: Methods for zooming in, out, resetting, and setting specific levels
- **Min/Max Clamping**: Prevents zoom from going too far in or out
- **Instant Option**: Bypass smoothing for immediate zoom changes
- **Signal Notifications**: Emits signal on zoom changes

### 4. Dead-Zone Support
- **Optional Feature**: Enable/disable dead-zone as needed
- **Configurable Size**: Adjust dead-zone width and height
- **Smooth Boundaries**: Camera only moves when target leaves dead-zone
- **Axis Independence**: Separate dead-zone handling for X and Y axes

### 5. Player Independence
- **No Hard Dependencies**: Works with any Node2D as a target
- **Reusable Design**: Can be used for following enemies, NPCs, or projectiles
- **Scene Flexibility**: Attach to any node in the scene tree
- **Configuration-Based**: All behavior controlled through exported parameters

### 6. Exposed API
- **Public Methods**: Clean API for triggering shake and controlling zoom
- **Query Methods**: Check camera state (is shaking, current zoom, etc.)
- **Signal System**: React to camera events in your game code
- **Documentation**: Comprehensive inline documentation with examples

## Class Overview

### Exported Parameters

#### Camera Follow Parameters
```gdscript
@export var follow_target: Node2D = null              # Target to follow (null = parent)
@export var smooth_follow: bool = true                # Enable smooth damping
@export var damping_speed_x: float = 5.0              # Horizontal damping speed
@export var damping_speed_y: float = 5.0              # Vertical damping speed
@export var independent_axis_damping: bool = false    # Separate X/Y damping
```

#### Dead-Zone Parameters
```gdscript
@export var enable_dead_zone: bool = false            # Enable dead-zone
@export var dead_zone_width: float = 100.0            # Dead-zone width (pixels)
@export var dead_zone_height: float = 80.0            # Dead-zone height (pixels)
```

#### Zoom Parameters
```gdscript
@export var base_zoom: Vector2 = Vector2(1.5, 1.5)    # Base zoom level
@export var smooth_zoom: bool = true                  # Smooth zoom transitions
@export var zoom_speed: float = 3.0                   # Zoom transition speed
@export var min_zoom: Vector2 = Vector2(0.5, 0.5)     # Minimum zoom
@export var max_zoom: Vector2 = Vector2(3.0, 3.0)     # Maximum zoom
```

#### Screen Shake Parameters
```gdscript
@export var default_shake_intensity: float = 10.0     # Default shake strength
@export var default_shake_duration: float = 0.3       # Default shake duration
@export var shake_decay: float = 5.0                  # Shake decay rate
@export var shake_frequency: float = 15.0             # Shake oscillation speed
```

### Public API Methods

#### Screen Shake
```gdscript
# Trigger screen shake with custom or default parameters
func shake(intensity: float = -1.0, duration: float = -1.0) -> void

# Check if shake is currently active
func is_shaking() -> bool

# Get current shake intensity
func get_shake_intensity() -> float
```

#### Zoom Control
```gdscript
# Set specific zoom level
func set_zoom(new_zoom: Vector2, instant: bool = false) -> void

# Reset to base zoom
func reset_zoom(instant: bool = false) -> void

# Zoom in by relative amount
func zoom_in(amount: float = 0.2) -> void

# Zoom out by relative amount
func zoom_out(amount: float = 0.2) -> void

# Get current/target zoom levels
func get_current_zoom() -> Vector2
func get_target_zoom() -> Vector2
```

#### Target and Follow Control
```gdscript
# Set follow target
func set_follow_target(target: Node2D) -> void

# Get current target
func get_follow_target() -> Node2D

# Toggle smooth follow
func enable_smooth_follow(enable: bool) -> void

# Set damping speed for both axes
func set_damping_speed(speed: float) -> void

# Configure dead-zone
func set_dead_zone(enabled: bool, width: float = 100.0, height: float = 80.0) -> void
```

### Signals

```gdscript
signal shake_started(intensity: float, duration: float)
signal shake_ended()
signal zoom_changed(new_zoom: Vector2)
```

## Usage Examples

### Basic Setup

1. **Add Camera to Scene**:
   - Add a Camera2D node to your scene
   - Attach the `cinematic_camera_2d.gd` script
   - The camera will automatically follow its parent node

2. **Configure in Inspector**:
   - Adjust damping speeds for desired smoothness
   - Set base zoom level
   - Configure shake parameters
   - Enable dead-zone if needed

### Example: Trigger Shake on Impact

```gdscript
extends CharacterBody2D

@export var camera: CinematicCamera2D

func _on_damage_taken(damage: float) -> void:
    # Shake intensity based on damage
    var shake_intensity = min(damage * 2.0, 30.0)
    camera.shake(shake_intensity, 0.4)
```

### Example: Dynamic Combat Zoom

```gdscript
extends Node2D

@export var camera: CinematicCamera2D

func _on_combat_started() -> void:
    # Zoom in during combat
    camera.set_zoom(Vector2(2.0, 2.0))

func _on_combat_ended() -> void:
    # Zoom back out
    camera.reset_zoom()
```

### Example: Boss Introduction

```gdscript
extends Node2D

@export var camera: CinematicCamera2D
@export var boss: Node2D

func _on_boss_appears() -> void:
    # Focus on boss
    camera.set_follow_target(boss)
    camera.set_zoom(Vector2(1.8, 1.8))
    
    # Dramatic shake
    camera.shake(20.0, 1.0)
    
    await get_tree().create_timer(3.0).timeout
    
    # Return to player
    camera.set_follow_target(get_node("Player"))
    camera.reset_zoom()
```

### Example: Cutscene Camera Control

```gdscript
extends Node2D

@export var camera: CinematicCamera2D
@export var waypoints: Array[Node2D]

func play_cutscene() -> void:
    # Disable smooth follow for precise control
    camera.enable_smooth_follow(false)
    
    for waypoint in waypoints:
        camera.set_follow_target(waypoint)
        await get_tree().create_timer(2.0).timeout
    
    # Re-enable smooth follow
    camera.enable_smooth_follow(true)
    camera.set_follow_target(get_node("Player"))
```

### Example: Dead-Zone for Platforming

```gdscript
extends Node2D

@export var camera: CinematicCamera2D

func _ready() -> void:
    # Enable dead-zone for less camera movement
    camera.set_dead_zone(true, 150.0, 100.0)
    
    # Use slower damping for platforming feel
    camera.set_damping_speed(3.0)
```

## Integration Guide

### Step 1: Add to Existing Scene

If you already have a Camera2D in your scene:
1. Select the Camera2D node
2. In the Inspector, attach `cinematic_camera_2d.gd` script
3. Configure exported parameters as desired

### Step 2: Replace Simple Camera

If creating from scratch:
1. Add a Camera2D node as child of your player/target
2. Attach `cinematic_camera_2d.gd` script
3. Enable the camera (check "Current" in Inspector)
4. Adjust settings in Inspector

### Step 3: Script Integration

```gdscript
# In your game controller or player script
@export var camera: CinematicCamera2D

func _ready() -> void:
    # Connect to camera signals
    camera.shake_started.connect(_on_camera_shake_started)
    camera.zoom_changed.connect(_on_camera_zoom_changed)

func _on_player_hit() -> void:
    camera.shake(12.0, 0.3)

func _on_zoom_in_requested() -> void:
    camera.zoom_in(0.5)
```

## Technical Details

### Architecture

The camera controller follows these design principles:

1. **Separation of Concerns**: Camera logic is independent of game logic
2. **Signal-Based Communication**: Events are emitted, not tightly coupled
3. **Configuration Over Code**: Most behavior controlled via exports
4. **Smooth Interpolation**: Uses lerp for all transitions
5. **Frame-Rate Independent**: All calculations use delta time

### Performance Considerations

- **Efficient Updates**: Only calculates shake when active
- **Cached References**: Target reference is cached to avoid lookups
- **Minimal Allocations**: Reuses Vector2 objects
- **Conditional Logic**: Dead-zone only calculated when enabled

### Godot 4 Features Used

- Modern GDScript 2.0 syntax
- Type hints throughout
- `@export` decorators with ranges
- `class_name` for easy scene integration
- Built-in documentation with `##`
- Signal system for events

## Testing

See `TEST_CAMERA.md` for comprehensive testing procedures.

A test scene is provided at `scenes/camera_test.tscn` which demonstrates all features.

## Compatibility

- **Godot Version**: 4.2 or later
- **Node Type**: Extends Camera2D
- **Dependencies**: None (fully standalone)

## Code Quality

- ✅ Clean, modular design
- ✅ Comprehensive inline documentation
- ✅ Type-safe with proper hints
- ✅ Organized into logical sections
- ✅ Follows established project conventions
- ✅ Export variables for editor configuration
- ✅ Public API with usage examples
- ✅ Signal-based event system

## Future Enhancement Ideas

While not implemented in this version, the camera could be extended with:

- Camera shake presets (small/medium/large)
- Zoom presets for common scenarios
- Camera bounds/limits
- Look-ahead based on movement direction
- Smooth rotation support
- Multiple target following (average position)
- Path-based camera movement
- Transition curves for zoom/follow

## License

This implementation follows the project's open source license and is available for educational and commercial use.
