# ECHOES OF ASH

A Godot 4 game project featuring a production-quality 2D player movement controller.

## Features

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
│   ├── player_2d.gd                    # Main player controller script
│   ├── dash_module.gd                  # Standalone dash module
│   └── dash_integration_example.gd     # Example dash integration
├── scenes/
│   ├── player.tscn                     # Player scene
│   └── main.tscn                       # Main game scene with platforms
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

### Using the Dash Module

To integrate the dash module into your game:

1. **Add the Module**: Add a `DashModule` node to your player scene or game manager
2. **Configure Parameters**: Adjust dash speed, duration, cooldown in the inspector
3. **Handle Input**: In your input handler, call `dash_module.dash(player, direction)` when dash is pressed
4. **Check Availability**: Use `dash_module.can_dash()` to check if dash is ready
5. **React to Events**: Connect to signals for visual/audio feedback
6. **Query State**: Use `is_dashing()` and `is_invincible()` for gameplay logic

Example integration code is provided in `scripts/dash_integration_example.gd`.

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
