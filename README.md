# ECHOES OF ASH

A Godot 4 game project featuring production-quality 2D systems including player movement, enemy AI, dash mechanics, melee combat, cinematic camera controller, atmospheric lighting, and a modular particle system.

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

### Melee Combat System

The game includes a modular melee combat controller (`MeleeCombatController`) for 2D action games:

#### 1. Combat Mechanics
- **Directional Melee Attacks**: Attack in different directions (left/right)
- **3-Hit Combo System**: Progressive combo chain with reset timer
- **Knockback Effects**: Scaled by enemy weight for dynamic physics
- **Attack Queuing**: Queue next attack during current attack
- **Configurable Parameters**: Adjust damage, knockback, and timing per combo hit

#### 2. Hitbox and Hurtbox System
- **Hitbox**: Modular offensive collision detection for attacks
- **Hurtbox**: Modular defensive collision detection for receiving damage
- **Automatic Collision Management**: Proper layer/mask configuration
- **Signal-Based**: Loose coupling through signal emissions

#### 3. Damage Handling
- **Invincibility Frames (i-frames)**: Temporary invincibility after taking damage
- **Weight-Based Knockback**: Heavier enemies receive less knockback
- **Automatic Knockback Application**: Applied to CharacterBody2D targets
- **Damage Signals**: React to damage events for visual/audio feedback

#### 4. Modular Design
- **No Movement Dependency**: Combat system is independent of player movement
- **Separation of Concerns**: Input handling is external to combat logic
- **Extensible Architecture**: Easy to add new attack types or abilities
- **Reusable Components**: Hitbox/Hurtbox can be used for any game object

#### 5. Code Quality
- Comprehensive documentation with inline comments
- Export variables for inspector configuration
- Type-safe implementation with proper type hints
- Example integration script provided (`combat_integration_example.gd`)
- Follows Godot 4 best practices

For detailed documentation, see [MELEE_COMBAT_SYSTEM.md](MELEE_COMBAT_SYSTEM.md).

### Atmospheric Lighting System

The game includes a comprehensive atmospheric lighting system (`LightingSystem`) for creating immersive 2D environments:

#### 1. Player-Following Light
- **Smooth Follow**: Configurable smoothing for natural light movement
- **Customizable Properties**: Adjust energy, color, scale, and offset
- **Runtime Control**: Enable/disable and modify properties during gameplay
- **Performance Optimized**: Minimal overhead with efficient updates

#### 2. Flickering Environmental Lights
- **Natural Animation**: Sine wave-based flickering with unique phases
- **Easy Placement**: Add lights at any position with custom colors
- **Dynamic Management**: Add/remove lights at runtime
- **Atmospheric Variation**: Each light has random frequency for natural feel

#### 3. Fog Layers
- **Multi-Layer Depth**: Configurable layer count for atmospheric depth
- **Color Customization**: Adjust fog color and transparency
- **Automatic Variation**: Layers have graduated alpha for depth effect
- **Toggle Support**: Enable/disable fog based on game state

#### 4. Performance-Safe Defaults
- Optimized for various hardware configurations
- Minimal per-frame calculations
- Efficient light and fog management
- Frame-rate independent animations

### Particle Manager

The game includes a modular particle effect system (`ParticleManager`) for dynamic visual feedback:

#### 1. Dash Trail Particles
- **Automatic Emission**: Follows player during dash action
- **Configurable Properties**: Adjust color, lifetime, and particle count
- **Signal Integration**: Works seamlessly with DashModule
- **Smooth Trails**: Timed emission for consistent trail effect

#### 2. Impact Particles
- **Directional Spread**: Particles respect impact direction
- **Combat Ready**: Perfect for hit effects and collisions
- **Gravity Support**: Realistic particle physics
- **Configurable Velocity**: Adjust speed and spread angle

#### 3. Dust Particles
- **Landing Effects**: Automatic dust on player landing
- **Velocity Influenced**: Dust direction follows player movement
- **Ground Interaction**: Perfect for platformer feel
- **Adjustable Intensity**: Configure particle count and lifetime

#### 4. Ambient Particles
- **Continuous Atmosphere**: Optional always-on particle effects
- **Customizable Patterns**: Adjust density, speed, and color
- **Performance Friendly**: Efficient spawning and management

### Enemy AI System

The game includes a modular, FSM-based enemy AI system with multiple behavior patterns:

#### 1. Patrol Behavior
- **Waypoint System**: Define patrol paths with multiple waypoints
- **Smooth Movement**: Uses move_and_slide() for proper physics
- **Flexible Patterns**: Loop or ping-pong between waypoints
- **Configurable Speed**: Adjust patrol speed per enemy

#### 2. Chase Behavior
- **Player Detection**: Automatic player tracking within range
- **Smooth Pursuit**: Natural movement toward player
- **Attack Range**: Stop at configurable distance
- **Dynamic Switching**: Seamlessly transitions between behaviors

#### 3. Attack Behavior
- **Cooldown System**: Prevents attack spam
- **Animation Ready**: Designed for easy animation integration
- **Damage Dealing**: Configurable damage values
- **Recovery State**: Returns to appropriate behavior after attack

#### 4. Finite State Machine
- **Clean Architecture**: State enum with clear transitions
- **Debug Support**: Exposed state variables for debugging
- **Extensible**: Easy to add new states and behaviors
- **Type-Safe**: Uses Godot 4 enums for compile-time safety

### Cinematic Camera Controller

The game includes a feature-rich 2D camera controller (`CinematicCameraController`) with smooth following, camera shake, zoom effects, and dead-zone control:

#### 1. Smooth Camera Follow
- **Configurable Smoothing**: Adjust follow speed (0.0 = instant, 1.0 = very smooth)
- **Target Tracking**: Follows any Node2D (player, enemies, objects)
- **Dead-Zone Support**: Optional movement threshold before camera reacts
- **Offset Control**: Adjust camera position relative to target

#### 2. Camera Shake
- **Trauma-Based System**: Realistic shake with decay over time
- **Configurable Intensity**: Adjust shake strength and duration
- **Multiple Shake Profiles**: Different shake patterns for various events
- **No Permanent Drift**: Camera returns to stable position after shake

#### 3. Zoom Effects
- **Smooth Zoom Transitions**: Interpolated zoom changes
- **Multiple Zoom Levels**: Predefined or custom zoom values
- **Runtime Control**: Change zoom based on gameplay events
- **Limit Support**: Configurable min/max zoom boundaries

#### 4. Dead-Zone System
- **Movement Threshold**: Camera doesn't move until player leaves zone
- **Customizable Size**: Adjust dead-zone dimensions
- **Smooth Transitions**: Natural camera movement at zone edges
- **Toggle Support**: Enable/disable dead-zone at runtime

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
- **Attack**: J or Z

## Project Structure

```
ECHOES-OF-ASH/
├── scripts/
│   ├── player_2d.gd                         # Main player controller script
│   ├── dash_module.gd                       # Standalone dash module
│   ├── dash_integration_example.gd          # Example dash integration
│   ├── melee_combat_controller.gd           # Melee combat system
│   ├── hitbox.gd                            # Offensive collision detection
│   ├── hurtbox.gd                           # Defensive collision detection
│   ├── combat_integration_example.gd        # Example combat integration
│   ├── test_combat_system.gd                # Combat system tests
│   ├── enemy_ai.gd                          # Modular enemy AI with FSM
│   ├── enemy_ai_test.gd                     # Enemy AI test scene script
│   ├── cinematic_camera_2d.gd               # Cinematic camera controller
│   ├── camera_test.gd                       # Camera test scene script
│   ├── lighting_system.gd                   # Atmospheric lighting system
│   ├── lighting_test.gd                     # Lighting test scene script
│   ├── particle_manager.gd                  # Modular particle manager
│   ├── particle_test.gd                     # Particle test scene script
│   └── atmospheric_integration.gd           # Lighting & particle integration
├── scenes/
│   ├── player.tscn                          # Player scene
│   ├── enemy.tscn                           # Example enemy scene
│   ├── enemy_ai_test.tscn                   # Enemy AI test scene
│   ├── camera_test.tscn                     # Camera test scene
│   ├── lighting_test.tscn                   # Lighting system test scene
│   ├── particle_test.tscn                   # Particle manager test scene
│   └── main.tscn                            # Main game scene with platforms
├── MELEE_COMBAT_SYSTEM.md                   # Combat system documentation
├── COMBAT_QUICK_REFERENCE.md                # Quick setup guide for combat
├── TEST_COMBAT_SYSTEM.md                    # Combat testing procedures
├── COMBAT_IMPLEMENTATION_SUMMARY.md         # Complete combat summary
├── PROJECT_HEALTH_REPORT.md                 # Project health analysis
├── CAMERA_IMPLEMENTATION_SUMMARY.md         # Complete camera documentation
├── CAMERA_QUICK_REFERENCE.md                # Quick setup guide for camera
├── TEST_CAMERA.md                           # Camera testing procedures
├── ENEMY_AI_IMPLEMENTATION_SUMMARY.md       # Complete enemy AI documentation
├── ENEMY_AI_QUICK_REFERENCE.md              # Quick setup guide for enemy AI
├── TEST_ENEMY_AI.md                         # Enemy AI testing procedures
├── FSM_IMPLEMENTATION_SUMMARY.md            # Player FSM documentation
├── DASH_MODULE.md                           # Dash module documentation
├── DASH_QUICK_REFERENCE.md                  # Quick setup guide for dash
├── TEST_DASH_MODULE.md                      # Dash testing procedures
├── DASH_IMPLEMENTATION_SUMMARY.md           # Complete dash summary
├── LIGHTING_IMPLEMENTATION_SUMMARY.md       # Complete lighting documentation
├── PARTICLE_MANAGER_IMPLEMENTATION_SUMMARY.md # Complete particle documentation
├── ATMOSPHERIC_QUICK_REFERENCE.md           # Quick setup for lighting & particles
├── icon.svg                                 # Project icon
├── project.godot                            # Godot project configuration
└── README.md                                # This file
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

### Combat Parameters (MeleeCombatController)
- `attack_1_duration`: Duration of first attack (default: 0.3 seconds)
- `attack_2_duration`: Duration of second attack (default: 0.35 seconds)
- `attack_3_duration`: Duration of third attack (default: 0.4 seconds)
- `combo_window`: Time to continue combo after attack (default: 0.5 seconds)
- `combo_reset_time`: Time before combo resets (default: 1.0 second)
- `attack_1_damage`: Damage of first attack (default: 10.0)
- `attack_2_damage`: Damage of second attack (default: 15.0)
- `attack_3_damage`: Damage of third attack (default: 25.0)
- `attack_1_knockback`: Knockback of first attack (default: 200.0)
- `attack_2_knockback`: Knockback of second attack (default: 300.0)
- `attack_3_knockback`: Knockback of third attack (default: 500.0)
- `enabled`: Whether combat is enabled (default: true)
- `attack_range`: Attack range from player center (default: 40.0 pixels)

### Hurtbox Parameters
- `iframe_duration`: Invincibility frame duration (default: 0.5 seconds)
- `weight`: Entity weight affecting knockback (default: 1.0)
- `vulnerable`: Whether hurtbox can take damage (default: true)

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

### Enemy AI Parameters (EnemyAI)
- `patrol_speed`: Speed when patrolling (default: 50.0)
- `chase_speed`: Speed when chasing player (default: 100.0)
- `detection_range`: Distance to detect player (default: 200.0)
- `attack_range`: Distance to attack player (default: 50.0)
- `attack_cooldown`: Time between attacks (default: 1.5)
- `attack_damage`: Damage dealt (default: 10.0)
- `patrol_wait_time`: Wait time at waypoints (default: 2.0)

### Lighting Parameters (LightingSystem)
- `player_light_energy`: Brightness of player light (default: 1.0)
- `player_light_color`: Color of player light (default: white)
- `light_follow_smoothness`: How smoothly light follows player (default: 5.0)
- `fog_enabled`: Whether fog is active (default: true)
- `fog_color`: Color of fog layers (default: semi-transparent blue)
- `fog_layer_count`: Number of fog layers (default: 3)

### Particle Parameters (ParticleManager)
- `dash_trail_color`: Color of dash trail particles (default: cyan)
- `dash_particle_lifetime`: How long dash particles last (default: 0.5)
- `impact_particle_count`: Number of impact particles (default: 20)
- `dust_particle_count`: Number of dust particles (default: 15)
- `ambient_enabled`: Whether ambient particles are active (default: false)

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

### Using the Melee Combat System

To integrate the combat system into your game:

1. **Add the Controller**: Add a `MeleeCombatController` node to your player
2. **Add Hitbox**: Add a `Hitbox` node as a child of the combat controller with a CollisionShape2D
3. **Add Hurtbox**: Add a `Hurtbox` node to your player with a CollisionShape2D
4. **Configure Parameters**: Adjust damage, knockback, and timing in the inspector
5. **Handle Input**: In your input handler, call `combat_controller.attack(direction)` when attack is pressed
6. **React to Events**: Connect to signals for visual/audio feedback

Example integration code is provided in `scripts/combat_integration_example.gd`.
For complete documentation, see [MELEE_COMBAT_SYSTEM.md](MELEE_COMBAT_SYSTEM.md).

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

### Using the Lighting System

To integrate the lighting system into your game:

1. **Add to Scene**: Add a Node2D to your scene and attach `lighting_system.gd`
2. **Configure in Inspector**: Enable features and adjust colors, fog, and light properties
3. **Setup Player Light**: Call `lighting_system.setup_player_light(player)` in your code
4. **Add Environmental Lights**: Use `add_flickering_light(position, color)` to place torches/lamps
5. **Darken Scene**: Add a CanvasModulate with dark color (e.g., Color(0.1, 0.1, 0.15)) for best effect
6. **Adjust at Runtime**: Use methods like `set_player_light_energy()` and `set_fog_enabled()`
7. **Test**: Use `lighting_test.tscn` to test all lighting features

Quick setup guide is provided in `ATMOSPHERIC_QUICK_REFERENCE.md`.
Complete documentation is in `LIGHTING_IMPLEMENTATION_SUMMARY.md`.

### Using the Particle Manager

To integrate the particle manager into your game:

1. **Add to Scene**: Add a Node2D to your scene and attach `particle_manager.gd`
2. **Integrate with Dash**: Connect dash signals to start/stop dash trail
3. **Add Impact Effects**: Call `spawn_impact(position, direction)` on collision
4. **Add Dust Effects**: Call `spawn_dust(position, velocity_x)` on landing
5. **Configure Particles**: Adjust colors, lifetimes, counts in the inspector
6. **Test**: Use `particle_test.tscn` to test all particle effects

Quick setup guide is provided in `ATMOSPHERIC_QUICK_REFERENCE.md`.
Complete documentation is in `PARTICLE_MANAGER_IMPLEMENTATION_SUMMARY.md`.

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
