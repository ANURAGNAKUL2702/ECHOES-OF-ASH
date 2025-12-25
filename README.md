# ECHOES OF ASH

A Godot 4 game project featuring a production-quality 2D player movement controller.

## Features

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
│   └── player_2d.gd          # Main player controller script
├── scenes/
│   ├── player.tscn            # Player scene
│   └── main.tscn              # Main game scene with platforms
├── icon.svg                   # Project icon
├── project.godot              # Godot project configuration
└── README.md                  # This file
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

## Technical Details

### Implementation Highlights

The `Player2D` controller uses Godot 4's `CharacterBody2D` class and implements:

1. **Physics Integration**: Leverages Godot's built-in physics with `move_and_slide()`
2. **Delta Time**: All movement calculations use delta time for frame-rate independence
3. **Input System**: Uses Godot 4's action-based input system
4. **State Management**: Tracks grounded state, timers, and jump consumption
5. **Public API**: Provides query methods like `is_jumping()`, `is_falling()`, etc.

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
