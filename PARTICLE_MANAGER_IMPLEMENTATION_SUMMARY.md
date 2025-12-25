# Particle Manager Implementation Summary

## Overview

The `ParticleManager` is a modular, extensible particle effect system for 2D action games in Godot 4. It provides pre-configured effects for dash trails, impacts, and dust, with an easy architecture for adding custom effects.

## Features

### 1. Dash Trail Particles
- Continuous trail emission during dash actions
- Follows the player automatically
- Configurable color, lifetime, and particle count
- Can be started/stopped programmatically

### 2. Impact Particles
- Directional impact effects for combat hits
- Configurable spread angle and velocity
- Gravity-affected for realistic falling
- Perfect for combat, collisions, and hits

### 3. Dust Particles
- Landing dust for jump/fall impacts
- Ground interaction effects
- Influenced by player velocity
- Great for platformer feel

### 4. Custom Effects
- Easily add new particle types
- Dictionary-based configuration
- Reusable effect templates
- Extensible architecture

### 5. Performance Management
- Automatic particle cleanup
- Maximum particle limit
- Pooling system
- GPU-accelerated particles

## Quick Start

### Basic Setup

1. **Add to Scene**
   ```
   Add a Node2D to your scene and attach the particle_manager.gd script
   ```

2. **Configure in Inspector**
   ```
   - Enable/disable effect types
   - Adjust colors, lifetimes, and particle counts
   - Set performance limits
   ```

3. **Basic Usage**
   ```gdscript
   # Spawn impact
   particle_manager.spawn_impact(player.global_position, Vector2.RIGHT)
   
   # Spawn dust
   particle_manager.spawn_dust(player.global_position, player.velocity.x)
   
   # Start dash trail
   particle_manager.start_dash_trail(player)
   # ... later ...
   particle_manager.stop_dash_trail()
   ```

## API Reference

### Dash Trail Methods

#### `start_dash_trail(target: Node2D) -> void`
Start emitting dash trail particles for a target.
- **target**: The Node2D to follow and emit trails from

#### `stop_dash_trail() -> void`
Stop emitting dash trail particles.

#### `spawn_dash_trail(pos: Vector2) -> void`
Manually spawn a single dash trail particle.
- **pos**: World position to spawn the trail

### Impact Methods

#### `spawn_impact(pos: Vector2, direction: Vector2 = Vector2.RIGHT) -> void`
Spawn impact particles at position.
- **pos**: World position to spawn the impact
- **direction**: Direction of impact for particle spread

### Dust Methods

#### `spawn_dust(pos: Vector2, velocity_x: float = 0.0) -> void`
Spawn dust particles at position.
- **pos**: World position to spawn dust
- **velocity_x**: Horizontal velocity to influence dust direction

### Custom Effect Methods

#### `add_custom_effect(effect_name: String, config: Dictionary) -> void`
Add a custom particle effect configuration.
- **effect_name**: Unique name for the effect
- **config**: Dictionary with effect parameters

Config dictionary parameters:
- `color`: Color of particles
- `lifetime`: Duration in seconds
- `scale`: Size multiplier
- `amount`: Number of particles
- `gravity`: Whether to apply gravity (bool)
- `initial_velocity`: Starting velocity as Vector2
- `spread`: Spread angle in degrees

#### `spawn_custom_effect(effect_name: String, pos: Vector2, direction: Vector2 = Vector2.ZERO) -> void`
Spawn a custom particle effect.
- **effect_name**: Name of registered custom effect
- **pos**: World position for effect
- **direction**: Direction vector for effect

### Configuration Methods

#### `set_effect_enabled(effect_type: String, enabled: bool) -> void`
Enable or disable a specific effect type.
- **effect_type**: "dash_trail", "impact", or "dust"
- **enabled**: true to enable, false to disable

#### `clear_all_particles() -> void`
Immediately remove all active particles.

### Query Methods

#### `get_active_particle_count() -> int`
Get the number of currently active particle systems.
- **Returns**: Count of active systems

#### `is_dashing() -> bool`
Check if dash trail is currently active.
- **Returns**: true if emitting dash trails

## Configuration Parameters

### Dash Trail Parameters
- `enable_dash_trails`: Enable/disable (default: true)
- `dash_trail_color`: Particle color (default: cyan/blue)
- `dash_trail_lifetime`: Duration in seconds (default: 0.3)
- `dash_trail_scale`: Size multiplier (default: 0.5)
- `dash_trail_amount`: Particles per emission (default: 3)
- `dash_trail_interval`: Time between emissions (default: 0.05)

### Impact Parameters
- `enable_impacts`: Enable/disable (default: true)
- `impact_color`: Particle color (default: yellow/gold)
- `impact_lifetime`: Duration in seconds (default: 0.4)
- `impact_scale`: Size multiplier (default: 1.0)
- `impact_particle_count`: Particles per impact (default: 15)
- `impact_spread_angle`: Spread in degrees (default: 120.0)
- `impact_velocity`: Initial velocity (default: 150.0)

### Dust Parameters
- `enable_dust`: Enable/disable (default: true)
- `dust_color`: Particle color (default: brownish)
- `dust_lifetime`: Duration in seconds (default: 0.5)
- `dust_scale`: Size multiplier (default: 0.8)
- `dust_particle_count`: Particles per emission (default: 8)
- `dust_spread`: Horizontal spread (default: 50.0)
- `dust_velocity`: Upward velocity (default: 80.0)

### General Parameters
- `particle_z_index`: Rendering layer (default: 100)
- `use_gravity`: Enable gravity for particles (default: true)
- `particle_gravity`: Gravity strength (default: 300.0)
- `max_active_particles`: Performance limit (default: 50)

## Usage Examples

### Example 1: Combat Integration
```gdscript
extends CharacterBody2D

@export var particle_manager: ParticleManager

func on_attack_hit(hit_position: Vector2, hit_direction: Vector2):
    # Spawn impact particles on hit
    particle_manager.spawn_impact(hit_position, hit_direction)

func on_take_damage(damage_position: Vector2):
    # Spawn impact when getting hit
    var direction = (global_position - damage_position).normalized()
    particle_manager.spawn_impact(global_position, direction)
```

### Example 2: Dash Integration
```gdscript
extends Node

@export var particle_manager: ParticleManager
@export var dash_module: DashModule
@export var player: CharacterBody2D

func _ready():
    # Connect to dash signals
    dash_module.dash_started.connect(_on_dash_started)
    dash_module.dash_ended.connect(_on_dash_ended)

func _on_dash_started():
    particle_manager.start_dash_trail(player)

func _on_dash_ended():
    particle_manager.stop_dash_trail()
    # Optional: spawn dust at end of dash
    particle_manager.spawn_dust(player.global_position, player.velocity.x)
```

### Example 3: Landing Detection
```gdscript
extends CharacterBody2D

@export var particle_manager: ParticleManager

var _was_airborne: bool = false

func _physics_process(_delta):
    var is_airborne = not is_on_floor()
    
    # Detect landing
    if _was_airborne and not is_airborne:
        var landing_velocity = abs(velocity.y)
        if landing_velocity > 200.0:  # Hard landing
            particle_manager.spawn_dust(global_position, velocity.x)
    
    _was_airborne = is_airborne
```

### Example 4: Custom Effects
```gdscript
# Create an explosion effect
particle_manager.add_custom_effect("explosion", {
    "color": Color(1.0, 0.3, 0.1, 1.0),
    "lifetime": 0.8,
    "scale": 1.5,
    "amount": 30,
    "gravity": true,
    "initial_velocity": Vector2(200, -150),
    "spread": 360.0
})

# Spawn it on bomb detonation
func detonate_bomb(position: Vector2):
    particle_manager.spawn_custom_effect("explosion", position)
```

### Example 5: Environmental Effects
```gdscript
# Create waterfall mist
particle_manager.add_custom_effect("waterfall_mist", {
    "color": Color(0.8, 0.9, 1.0, 0.3),
    "lifetime": 2.0,
    "scale": 0.6,
    "amount": 10,
    "gravity": false,
    "initial_velocity": Vector2(0, 50),
    "spread": 30.0
})

# Spawn continuously near waterfall
func _process(_delta):
    if near_waterfall:
        particle_manager.spawn_custom_effect("waterfall_mist", waterfall_position)
```

## Integration with Game Systems

### With AtmosphericIntegration
The `AtmosphericIntegration` script provides automatic integration:
```gdscript
# Automatically handles:
# - Dash trail start/stop via DashModule signals
# - Landing dust detection
# - Provides convenience methods
var integration = $AtmosphericIntegration

# Use convenience methods
integration.spawn_impact_at_player(Vector2.RIGHT)
```

### With DashModule
Direct integration with the dash system:
```gdscript
# In your player script or dash integration
func _on_dash_started():
    particle_manager.start_dash_trail(self)

func _on_dash_ended():
    particle_manager.stop_dash_trail()
```

## Signals

### `particle_spawned(effect_type: String, position: Vector2)`
Emitted when a particle effect is spawned.
- **effect_type**: Name of the effect
- **position**: World position where spawned

### `particle_system_initialized()`
Emitted when the particle system is ready.

## Performance Considerations

1. **Particle Limit**: Default max of 50 active systems
2. **Automatic Cleanup**: Old particles are removed automatically
3. **GPU Acceleration**: Uses GPUParticles2D for performance
4. **Effect Optimization**: Pre-configured effects use efficient settings

### Performance Tips
- Keep `max_active_particles` reasonable (30-50)
- Use lower particle counts for frequent effects
- Disable unused effect types
- Use shorter lifetimes when possible

## Testing

Use the `particle_test.tscn` scene to test all features:
- Dash trails (hold Q)
- Impact particles (press W)
- Dust particles (press E)
- Custom explosion (press R)
- Toggle effects (1, 2, 3)
- Clear particles (C)

Run with: `res://scenes/particle_test.tscn`

## Advanced Usage

### Creating Effect Presets
```gdscript
# Define presets for easy reuse
const EFFECT_PRESETS = {
    "fire": {
        "color": Color(1.0, 0.5, 0.1),
        "lifetime": 0.6,
        "scale": 1.2,
        "amount": 20,
        "gravity": true,
        "initial_velocity": Vector2(0, -100),
        "spread": 45.0
    },
    "magic": {
        "color": Color(0.5, 0.3, 1.0),
        "lifetime": 1.0,
        "scale": 0.8,
        "amount": 15,
        "gravity": false,
        "initial_velocity": Vector2(50, 0),
        "spread": 360.0
    }
}

func _ready():
    for preset_name in EFFECT_PRESETS:
        particle_manager.add_custom_effect(preset_name, EFFECT_PRESETS[preset_name])
```

### Chaining Effects
```gdscript
# Chain multiple effects for complex visuals
func heavy_landing(position: Vector2):
    particle_manager.spawn_dust(position, 0)
    await get_tree().create_timer(0.1).timeout
    particle_manager.spawn_impact(position, Vector2.DOWN)
```

## Troubleshooting

### Particles Not Visible
- Check if effects are enabled in configuration
- Verify particle colors have sufficient alpha
- Ensure particles aren't spawning off-screen
- Check z-index settings

### Performance Issues
- Reduce `max_active_particles`
- Lower particle counts per effect
- Decrease particle lifetimes
- Disable unused effects

### Dash Trails Not Working
- Ensure `start_dash_trail()` is called with valid target
- Check dash trail is enabled
- Verify target node exists and is valid

## Future Extensions

The system is designed for easy extension:
- Add trail variations (fire, ice, etc.)
- Implement particle pooling for better performance
- Add particle animations/textures
- Create particle effect chains
- Add sound integration for particles
- Implement weather particle systems
