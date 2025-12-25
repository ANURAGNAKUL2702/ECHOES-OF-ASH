# ECHOES OF ASH

A Godot 4 game project featuring production-quality 2D systems including player movement, enemy AI, dash mechanics, and a cinematic camera controller.

## Features

### Cinematic Camera Controller

The game includes a comprehensive cinematic camera system (`CinematicCamera2D`) with professional camera behaviors:

#### 1. Smooth Camera Follow
- **Configurable Damping**: Independent X/Y axis damping for smooth follow effect
- **Flexible Targeting**: Can follow any Node2D or automatically follow parent
- **Player Independence**: No direct dependencies on player movement logic
- **Toggle Capability**: Switch between smooth and instant follow modes

#### 2. Screen Shake Effects
- **Dynamic Shake**: Trigger shake with custom intensity and duration
- **Smooth Oscillation**: Natural-looking shake using sine/cosine waves
- **Automatic Decay**: Shake intensity decreases smoothly over time
- **Configurable Frequency**: Adjust shake speed for different impact types
- **Signal-Based**: Emits signals when shake starts and ends

#### 3. Dynamic Zoom
- **Smooth Transitions**: Interpolated zoom changes for cinematic effect
- **Multiple Methods**: Zoom in, out, reset, or set specific levels
- **Clamped Range**: Respects min/max zoom constraints
- **Instant Option**: Bypass smoothing for immediate zoom changes
- **Signal Notifications**: Emits events on zoom changes

#### 4. Dead-Zone Support
- **Optional Feature**: Enable/disable as needed for different game modes
- **Configurable Size**: Adjust dead-zone width and height independently
- **Smooth Boundaries**: Camera only moves when target leaves dead-zone area
- **Platformer-Friendly**: Great for stable platforming camera behavior

#### 5. Exposed API
- **Public Methods**: `shake()` and `set_zoom()` for triggering effects
- **Query Methods**: Check camera state (is shaking, current zoom, etc.)
- **Signal System**: React to camera events in game code
- **Target Control**: Change follow targets dynamically

#### 6. Code Quality
- Clean, well-documented code with comprehensive inline documentation
- Fully configurable via @export parameters in Godot editor
- Type-safe implementation with proper type hints
- Test scene and integration examples provided

### Enemy AI System

The game includes a complete modular enemy AI system with a finite state machine for intelligent enemy behavior:

#### 1. State Machine with 6 States
- **PATROL**: Enemy patrols an area or stays idle with configurable movement patterns
- **DETECT**: Enemy spots target and observes briefly before acting
- **CHASE**: Enemy actively pursues the detected target
- **ATTACK**: Enemy is in range and attacks via signal-based interface
- **STUNNED**: Enemy is temporarily disabled with configurable duration
- **DEATH**: Enemy has been defeated (permanent state)

#### 2. Line of Sight Detection
- **RayCast2D Integration**: Realistic vision that can be blocked by obstacles
- **Detection Range**: Tunable parameter for how far enemies can see (default: 400 pixels)
- **Detection Angle**: Configurable field of view (default: 180 degrees, supports up to 360)
- **Target Groups**: Uses Godot groups instead of hard-coded player references

#### 3. Modular Design
- **No Hard Dependencies**: Uses signals and groups for clean separation
- **Combat Separation**: Attack logic handled externally via `attack_ready` signal
- **Reusable**: Easy to create different enemy types by extending or configuring
- **Signal-Based**: Emits events for detection, attacks, stun, and death

#### 4. Tunable Parameters
All parameters exposed via @export for easy customization:
- Movement speeds (patrol and chase)
- Detection range and angle
- Attack range and cooldown
- Patrol distance and wait times
- Stun duration and immunity

#### 5. Code Quality
- Clean, modular design following same patterns as player FSM
- Comprehensive documentation with usage examples
- Type-safe implementation with proper type hints
- Example integration scripts and test scenes provided

### Finite State Machine (FSM)

The player controller now includes a clean, production-ready finite state machine with the following features:

#### States
- **IDLE**: Player is on the ground and not moving
- **RUN**: Player is on the ground and moving horizontally  
- **JUMP**: Player is in the air and moving upward
- **FALL**: Player is in the air and moving downward

#### State Management
- **Type-Safe Design**: States are defined as an enum for compile-time safety
- **Exposed Variables**: `current_state` and `previous_state` are accessible for debugging and external logic
- **Clean API**: 
  - `set_state(state: State)`: Switch to a new state with automatic previous state tracking
  - `update_state(dt: float)`: Extension point for state-specific frame updates
  - `physics_update_state()`: Automatically determines and transitions between states based on player movement
  - `get_state_name() -> String`: Returns current state as a human-readable string

#### Modularity
- **Easy to Extend**: Add new states by extending the `State` enum and adding cases to the `match` statements
- **Separation of Concerns**: Movement logic remains separate from state management
- **Future-Ready**: Placeholder methods allow easy addition of state-specific behavior (animations, effects, etc.)

### Dash Module

The game includes a standalone, modular dash system (`DashModule`) for adding dash mechanics to any 2D character:

#### 1. Dash Mechanics
- **Horizontal Burst Movement**: Short, fast dash with configurable speed and duration
- **Direction Control**: Auto-detect direction from player movement or specify manually
- **Configurable Parameters**: Easily adjust dash speed, duration, and cooldown in the editor

#### 2. Cooldown and Invincibility
- **Cooldown System**: Prevents consecutive dashes with customizable cooldown timer
- **Invincibility Frames (i-frames)**: Temporary invincibility during dash for enhanced survivability
- **Cooldown Progress**: Query cooldown state programmatically with `get_cooldown_progress()`

#### 3. Enable/Disable Functionality
- **Progression Support**: Toggle dash on/off for ability unlocking or temporary disabling
- **Simple API**: Use `set_enabled(bool)` to control dash availability

#### 4. Interface Design
- **Separation of Concerns**: Module does NOT read input directly
- **Clean API**: Call `dash(player, direction)` from your input handler
- **Query Methods**: Check state with `can_dash()`, `is_dashing()`, `is_invincible()`
- **Signals**: React to dash events with `dash_started`, `dash_ended`, and `dash_ready` signals
- **No Dependencies**: Completely standalone, no coupling to combat or camera systems

#### 5. Code Quality
- Clean, modular design with comprehensive documentation
- Export variables for easy customization in Godot editor
- Type-safe implementation with proper type hints
- Example integration script provided (`dash_integration_example.gd`)

### Player Movement Controller

The game includes a robust 2D player movement controller (`Player2D`) with the following features:

#### 1. Horizontal Movement
- **Smooth Acceleration**: Gradual speed increase when moving left or right
- **Smooth Deceleration**: Natural slowdown when stopping
- **Air Control**: Reduced but functional control while airborne

#### 2. Jumping Mechanics
- **Gravity-Based Jumping**: Physics-based vertical movement
- **Variable Jump Height**: Hold jump longer for higher jumps
- **Coyote Time**: Jump briefly after walking off edges (0.15s default)
- **Jump Buffering**: Press jump slightly before landing (0.1s default)
- **Enhanced Fall Physics**: Faster falling for snappier gameplay

#### 3. Code Quality
- Clean, well-documented code with inline comments
- Modular design with clear separation of concerns
- Export variables for easy tweaking in the Godot editor
- Proper type hints throughout for better IDE support
- Organized into logical sections for maintainability

## Getting Started

### Prerequisites
- Godot 4.2 or later

### Installation
1. Clone this repository
2. Open the project in Godot 4
3. Run the project (F5) or open `scenes/main.tscn`

### Controls
- **Move Left**: A or Left Arrow
- **Move Right**: D or Right Arrow  
- **Jump**: Space, W, or Up Arrow

## Project Structure

```
ECHOES-OF-ASH/
├── scripts/
│   ├── player_2d.gd                     # Main player controller script
│   ├── dash_module.gd                   # Standalone dash module
│   ├── dash_integration_example.gd      # Example dash integration
│   ├── enemy_ai.gd                      # Modular enemy AI controller
│   ├── enemy_integration_example.gd     # Example enemy integration
│   ├── enemy_ai_test.gd                 # Enemy AI test scene script
│   ├── cinematic_camera_2d.gd           # Cinematic camera controller
│   └── camera_test.gd                   # Camera test scene script
├── scenes/
│   ├── player.tscn                      # Player scene
│   ├── enemy.tscn                       # Example enemy scene
│   ├── enemy_ai_test.tscn               # Enemy AI test scene
│   ├── camera_test.tscn                 # Camera test scene
│   └── main.tscn                        # Main game scene with platforms
├── CAMERA_IMPLEMENTATION_SUMMARY.md     # Complete camera documentation
├── CAMERA_QUICK_REFERENCE.md            # Quick setup guide for camera
├── TEST_CAMERA.md                       # Camera testing procedures
├── ENEMY_AI_IMPLEMENTATION_SUMMARY.md   # Complete enemy AI documentation
├── ENEMY_AI_QUICK_REFERENCE.md          # Quick setup guide for enemy AI
├── TEST_ENEMY_AI.md                     # Enemy AI testing procedures
├── FSM_IMPLEMENTATION_SUMMARY.md        # Player FSM documentation
├── DASH_MODULE.md                       # Dash module documentation
├── icon.svg                            # Project icon
├── project.godot                       # Godot project configuration
└── README.md                           # This file
```

## Customization

The player controller exposes many parameters that can be adjusted in the Godot editor:

### Movement Parameters
- `max_speed`: Maximum horizontal speed (default: 300)
- `acceleration`: How quickly the player speeds up (default: 2000)
- `friction`: How quickly the player slows down (default: 2500)
- `air_resistance`: Air control multiplier (default: 0.5)

### Jump Parameters
- `jump_velocity`: Initial jump force (default: -450)
- `gravity_multiplier`: Overall gravity strength (default: 1.0)
- `fall_gravity_multiplier`: Extra gravity when falling (default: 1.5)
- `max_fall_speed`: Terminal velocity (default: 800)

### Advanced Jump Parameters
- `coyote_time`: Grace period for jumping after leaving ground (default: 0.15s)
- `jump_buffer_time`: How early you can press jump before landing (default: 0.1s)
- `jump_height_control`: Variable jump height sensitivity (default: 0.5)

### Dash Parameters (DashModule)
- `dash_speed`: Speed during dash (default: 600 pixels/second)
- `dash_duration`: How long the dash lasts (default: 0.2 seconds)
- `dash_cooldown`: Time between dashes (default: 1.0 second)
- `iframe_duration`: Invincibility frame duration (default: 0.15 seconds)
- `enabled`: Whether dash is unlocked (default: true)
- `lock_direction`: Prevents direction change during dash (default: true)
- `dash_control`: Control influence during unlocked dash (default: 0.8)

### Camera Parameters (CinematicCamera2D)
- `damping_speed_x`: Horizontal follow smoothness (default: 5.0)
- `damping_speed_y`: Vertical follow smoothness (default: 5.0)
- `base_zoom`: Default camera zoom level (default: Vector2(1.5, 1.5))
- `zoom_speed`: Zoom transition speed (default: 3.0)
- `min_zoom`: Minimum zoom level (default: Vector2(0.5, 0.5))
- `max_zoom`: Maximum zoom level (default: Vector2(3.0, 3.0))
- `default_shake_intensity`: Default shake strength in pixels (default: 10.0)
- `default_shake_duration`: Default shake duration in seconds (default: 0.3)
- `shake_decay`: How quickly shake fades (default: 5.0)
- `shake_frequency`: Shake oscillation speed (default: 15.0)
- `dead_zone_width`: Dead-zone width in pixels (default: 100.0)
- `dead_zone_height`: Dead-zone height in pixels (default: 80.0)

## Technical Details

### Implementation Highlights

The `Player2D` controller uses Godot 4's `CharacterBody2D` class and implements:

1. **Finite State Machine**: Clean FSM with Idle, Run, Jump, and Fall states for organized game logic
2. **Physics Integration**: Leverages Godot's built-in physics with `move_and_slide()`
3. **Delta Time**: All movement calculations use delta time for frame-rate independence
4. **Input System**: Uses Godot 4's action-based input system
5. **State Management**: Tracks grounded state, timers, jump consumption, and FSM states
6. **Public API**: Provides query methods like `is_jumping()`, `is_falling()`, `get_state_name()`, etc.

The `DashModule` is a standalone node that can be added to any project:

1. **Modular Design**: Completely independent, no dependencies on other game systems
2. **Signal-Based**: Emits signals for dash events (`dash_started`, `dash_ended`, `dash_ready`)
3. **Timer Management**: Handles cooldown, dash duration, and i-frame timers automatically
4. **Flexible Integration**: Works with any `CharacterBody2D` through the `dash(player)` method
5. **Separation of Concerns**: Does NOT read input directly - input handling is external
6. **Query Methods**: Provides `can_dash()`, `is_dashing()`, `is_invincible()` for state checking

The `CinematicCamera2D` extends Godot's Camera2D with cinematic features:

1. **Smooth Follow System**: Configurable damping with independent X/Y axis control
2. **Screen Shake**: Sine/cosine wave-based shake with automatic decay
3. **Dynamic Zoom**: Smooth interpolated zoom with clamped min/max values
4. **Dead-Zone Support**: Optional feature for stable platforming cameras
5. **Player Independence**: Works with any Node2D target, not just players
6. **Signal System**: Emits events for shake and zoom changes
7. **Performance Optimized**: Minimal calculations, cached references, frame-rate independent

### Using the Dash Module

To integrate the dash module into your game:

1. **Add the Module**: Add a `DashModule` node to your player scene or game manager
2. **Configure Parameters**: Adjust dash speed, duration, cooldown in the inspector
3. **Handle Input**: In your input handler, call `dash_module.dash(player, direction)` when dash is pressed
4. **Check Availability**: Use `dash_module.can_dash()` to check if dash is ready
5. **React to Events**: Connect to signals for visual/audio feedback
6. **Query State**: Use `is_dashing()` and `is_invincible()` for gameplay logic

Example integration code is provided in `scripts/dash_integration_example.gd`.

### Using the Enemy AI

To integrate enemy AI into your game:

1. **Add Enemy to Scene**: Instance `enemy.tscn` or attach `enemy_ai.gd` to a CharacterBody2D
2. **Add RayCast2D**: Add a RayCast2D child for line of sight detection
3. **Configure Target**: Ensure player/target is in the "player" group
4. **Configure Parameters**: Adjust detection range, speeds, patrol settings in the inspector
5. **Connect Signals**: Connect to `attack_ready`, `died`, etc. for combat integration
6. **Test**: Use `enemy_ai_test.tscn` to see the AI in action

Quick setup guide is provided in `ENEMY_AI_QUICK_REFERENCE.md`.
Complete documentation is in `ENEMY_AI_IMPLEMENTATION_SUMMARY.md`.

### Using the Cinematic Camera

To integrate the cinematic camera into your game:

1. **Add Camera to Scene**: Add a Camera2D node to your player or scene
2. **Attach Script**: Attach `cinematic_camera_2d.gd` to the Camera2D node
3. **Enable Camera**: Check "Current" in the Inspector to enable the camera
4. **Configure Parameters**: Adjust damping, zoom, shake, and dead-zone settings in the inspector
5. **Trigger Effects**: Call `camera.shake()` for impacts, `camera.set_zoom()` for dramatic moments
6. **Connect Signals**: Connect to `shake_started`, `zoom_changed` for visual/audio feedback
7. **Test**: Use `camera_test.tscn` to test all camera features

Quick setup guide is provided in `CAMERA_QUICK_REFERENCE.md`.
Complete documentation is in `CAMERA_IMPLEMENTATION_SUMMARY.md`.

### Godot 4 Compatibility

This controller is built specifically for Godot 4 and uses:
- Modern GDScript 2.0 syntax
- Type hints and annotations
- `@export` decorators for inspector properties
- `@export_range` for clamped values
- Class name declaration with `class_name`
- Built-in documentation comments with `##`

## License

This project is open source and available for educational and commercial use.

## Contributing

Contributions are welcome! Feel free to submit issues or pull requests.

## Acknowledgments

Built with ♥ using Godot Engine 4
