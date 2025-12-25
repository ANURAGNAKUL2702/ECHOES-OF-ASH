# Atmospheric Systems Quick Reference

Quick setup guide for LightingSystem and ParticleManager in Godot 4.

## LightingSystem - Quick Setup

### 1. Add to Scene
```
Scene Tree:
└── YourScene
    └── LightingSystem (Node2D with lighting_system.gd)
```

### 2. Initialize
```gdscript
@export var lighting_system: LightingSystem
@export var player: CharacterBody2D

func _ready():
    lighting_system.setup_player_light(player)
```

### 3. Add Lights
```gdscript
# Add flickering environmental lights
lighting_system.add_flickering_light(Vector2(100, 100))
lighting_system.add_flickering_light(Vector2(300, 100), Color(1.0, 0.5, 0.2))
```

### 4. Adjust at Runtime
```gdscript
# Adjust player light
lighting_system.set_player_light_energy(1.5)
lighting_system.set_player_light_color(Color(0.7, 0.9, 1.0))

# Toggle fog
lighting_system.set_fog_enabled(true)
lighting_system.set_fog_color(Color(0.1, 0.1, 0.2, 0.4))
```

## ParticleManager - Quick Setup

### 1. Add to Scene
```
Scene Tree:
└── YourScene
    └── ParticleManager (Node2D with particle_manager.gd)
```

### 2. Basic Effects
```gdscript
@export var particle_manager: ParticleManager

# Spawn impact
particle_manager.spawn_impact(position, direction)

# Spawn dust
particle_manager.spawn_dust(position, velocity_x)
```

### 3. Dash Integration
```gdscript
# Connect to dash signals
dash_module.dash_started.connect(_on_dash_started)
dash_module.dash_ended.connect(_on_dash_ended)

func _on_dash_started():
    particle_manager.start_dash_trail(player)

func _on_dash_ended():
    particle_manager.stop_dash_trail()
```

### 4. Custom Effects
```gdscript
# Define custom effect
particle_manager.add_custom_effect("explosion", {
    "color": Color.RED,
    "lifetime": 0.8,
    "scale": 2.0,
    "amount": 30,
    "gravity": true,
    "initial_velocity": Vector2(200, -150),
    "spread": 360.0
})

# Spawn it
particle_manager.spawn_custom_effect("explosion", position)
```

## Complete Integration Example

### Scene Structure
```
Main
├── Player (CharacterBody2D)
├── LightingSystem (Node2D)
├── ParticleManager (Node2D)
├── DashModule (Node)
└── AtmosphericIntegration (Node)
```

### Integration Script
```gdscript
extends Node

@export var lighting_system: LightingSystem
@export var particle_manager: ParticleManager
@export var dash_module: DashModule
@export var player: CharacterBody2D

func _ready():
    # Setup lighting
    lighting_system.setup_player_light(player)
    
    # Add environmental lights
    lighting_system.add_flickering_light(Vector2(200, 300))
    
    # Connect dash signals
    dash_module.dash_started.connect(_on_dash_started)
    dash_module.dash_ended.connect(_on_dash_ended)

func _on_dash_started():
    particle_manager.start_dash_trail(player)

func _on_dash_ended():
    particle_manager.stop_dash_trail()
```

## Common Use Cases

### Landing Dust
```gdscript
var _was_airborne = false

func _physics_process(_delta):
    if _was_airborne and is_on_floor():
        if abs(velocity.y) > 200:
            particle_manager.spawn_dust(global_position, velocity.x)
    _was_airborne = not is_on_floor()
```

### Combat Hit Effects
```gdscript
func on_hit(hit_pos: Vector2, hit_dir: Vector2):
    particle_manager.spawn_impact(hit_pos, hit_dir)
```

### Dynamic Lighting
```gdscript
func enter_dark_cave():
    lighting_system.set_player_light_energy(1.8)
    lighting_system.set_fog_color(Color(0.05, 0.05, 0.1, 0.6))

func exit_cave():
    lighting_system.set_player_light_energy(0.8)
    lighting_system.set_fog_enabled(false)
```

## Essential Configuration

### Lighting - Best Defaults
```
Player Light:
- Energy: 1.0 - 1.5
- Scale: 1.5 - 2.5
- Color: Warm white (1.0, 0.9, 0.7)
- Smoothing: 8.0 - 12.0

Flickering:
- Base Energy: 0.7 - 1.0
- Intensity: 0.3 - 0.5
- Speed: 2.0 - 4.0

Fog:
- Layers: 2
- Color: Dark with low alpha (0.15, 0.15, 0.2, 0.3)
```

### Particles - Best Defaults
```
Dash Trail:
- Amount: 3 - 5
- Lifetime: 0.2 - 0.4
- Interval: 0.04 - 0.06

Impact:
- Count: 15 - 25
- Lifetime: 0.3 - 0.5
- Spread: 90 - 150 degrees

Dust:
- Count: 8 - 12
- Lifetime: 0.4 - 0.6
- Velocity: 60 - 100
```

## Test Scenes

### Test Lighting
```
Run: res://scenes/lighting_test.tscn

Controls:
1 - Toggle player light
2 - Toggle flickering lights
3 - Toggle fog
4 - Cycle light colors
5 - Add random light
+/- - Adjust brightness
```

### Test Particles
```
Run: res://scenes/particle_test.tscn

Controls:
Q - Dash trail (hold)
W - Impact effect
E - Dust effect
R - Explosion (custom)
1/2/3 - Toggle effects
C - Clear all particles
```

## Performance Tips

1. **Lighting**
   - Keep flickering lights < 20 on screen
   - Use 1-3 fog layers
   - Disable fog in bright areas

2. **Particles**
   - Set max_active_particles to 30-50
   - Lower counts for frequent effects
   - Use shorter lifetimes
   - Disable unused effect types

## Troubleshooting

### Lights not visible
→ Add CanvasModulate with dark color (0.1, 0.1, 0.15)

### Particles not showing
→ Check z_index, ensure effects are enabled

### Performance lag
→ Reduce particle/light counts, lower fog layers

## Documentation

Full documentation:
- `LIGHTING_IMPLEMENTATION_SUMMARY.md`
- `PARTICLE_MANAGER_IMPLEMENTATION_SUMMARY.md`
