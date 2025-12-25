# Melee Combat Controller

A production-quality modular melee combat system for 2D action games in Godot 4.

## Overview

The Melee Combat Controller provides a complete, extensible combat system with the following components:

1. **MeleeCombatController** - Core combat logic and combo management
2. **Hitbox** - Offensive collision detection for attacks
3. **Hurtbox** - Defensive collision detection for receiving damage
4. **Combat Integration Example** - Demonstration of combining combat with movement

## Features

### 1. Combat Mechanics

#### Directional Melee Attacks
- Support for attacking in different directions (left/right)
- Auto-detection of facing direction from player movement or sprite orientation
- Manual direction specification for precise control

#### 3-Hit Combo System
- Progressive combo chain (1 → 2 → 3)
- Configurable combo window for chaining attacks
- Automatic combo reset after timeout
- Attack queuing during active attacks

#### Combo Parameters
- **Attack Duration**: Each combo hit has independent duration
- **Combo Window**: Time window to continue combo after attack ends
- **Combo Reset Time**: Idle time before combo resets to zero
- **Damage Scaling**: Each combo hit can have different damage values
- **Knockback Scaling**: Progressive knockback force per combo hit

#### Knockback Effects
- Knockback force applied to targets on hit
- Scaled by enemy weight (heavier enemies = less knockback)
- Directional knockback based on attack direction
- Automatic application to CharacterBody2D targets

### 2. Hitbox and Hurtbox System

#### Hitbox (Offensive)
- Modular Area2D-based collision detection
- Configurable damage and knockback values
- Can be enabled/disabled for precise attack timing
- Supports multiple hitboxes per character
- Emits signals when hitting targets
- Automatic collision layer management

#### Hurtbox (Defensive)
- Modular Area2D-based damage reception
- Invincibility frames (i-frames) after taking damage
- Weight system for knockback scaling
- Automatic knockback application to parent CharacterBody2D
- Emits signals for damage events and i-frame state
- Automatic collision layer management

### 3. Damage Handling

#### Invincibility Frames
- Configurable i-frame duration on Hurtbox
- Automatic vulnerability management
- Signal emission for i-frame start/end
- Progress tracking (0.0 = vulnerable, 1.0 = just hit)

#### Damage Flow
1. Hitbox overlaps with Hurtbox
2. Hurtbox checks if vulnerable (not in i-frames)
3. Damage is applied and signal emitted
4. Knockback is calculated and applied (scaled by weight)
5. I-frames are activated
6. Parent receives damage_taken signal

### 4. Modular Design

#### Separation of Concerns
- Combat controller has no direct dependency on player movement
- Input handling is external to combat system
- Each component (Hitbox/Hurtbox/Controller) is independent
- Signals provide loose coupling for game logic

#### Extensibility
- Easy to add new attack types (heavy, special, aerial)
- Simple to extend combo system beyond 3 hits
- Straightforward to add status effects or buffs
- Clean API for integration with other systems

### 5. Code Quality

#### Best Practices
- Comprehensive inline documentation
- Type hints throughout for IDE support
- Export variables for inspector configuration
- Signal-based architecture for decoupling
- Follows Godot 4 coding standards
- Clean, maintainable code structure

## Getting Started

### Prerequisites
- Godot 4.2 or later

### Installation

1. Copy the combat system scripts to your project:
   - `scripts/melee_combat_controller.gd`
   - `scripts/hitbox.gd`
   - `scripts/hurtbox.gd`
   - `scripts/combat_integration_example.gd` (optional)

2. Add the "attack" input action to your project.godot:
   ```gdscript
   attack={
   "deadzone": 0.5,
   "events": [Object(InputEventKey,"resource_local_to_scene":false,"resource_name":"","device":-1,"window_id":0,"alt_pressed":false,"shift_pressed":false,"ctrl_pressed":false,"meta_pressed":false,"pressed":false,"keycode":0,"physical_keycode":74,"key_label":0,"unicode":106,"echo":false,"script":null)]
   }
   ```

### Basic Setup

#### For Player Character:

1. **Add Combat Controller**:
   - Add `MeleeCombatController` node as a child of your player

2. **Add Hitbox**:
   - Add `Hitbox` node as a child of `MeleeCombatController`
   - Add `CollisionShape2D` child to Hitbox
   - Configure collision shape (RectangleShape2D or CircleShape2D)

3. **Add Hurtbox**:
   - Add `Hurtbox` node as a child of your player
   - Add `CollisionShape2D` child to Hurtbox
   - Configure collision shape to cover player's vulnerable area

4. **Configure in Inspector**:
   - Adjust combat parameters (damage, knockback, timing)
   - Set i-frame duration on Hurtbox
   - Set weight on Hurtbox (1.0 = default)

5. **Handle Input**:
   ```gdscript
   func _physics_process(delta: float) -> void:
       if Input.is_action_just_pressed("attack"):
           var direction = get_facing_direction()
           $MeleeCombatController.attack(direction)
   ```

6. **Connect Signals** (optional):
   ```gdscript
   func _ready() -> void:
       $MeleeCombatController.attack_started.connect(_on_attack_started)
       $MeleeCombatController.damage_received.connect(_on_damage_taken)
   ```

#### For Enemy Character:

Enemies only need a Hurtbox to receive damage:

1. Add `Hurtbox` node as a child of enemy
2. Add `CollisionShape2D` child to Hurtbox
3. Configure weight (higher = less knockback)
4. Connect to `damage_taken` signal for AI responses

## Usage Examples

### Basic Attack

```gdscript
# Simple attack execution
func _input(event: InputEvent) -> void:
    if event.is_action_pressed("attack"):
        $MeleeCombatController.attack()
```

### Directional Attack

```gdscript
# Attack in a specific direction
func attack_left() -> void:
    $MeleeCombatController.attack(-1.0)

func attack_right() -> void:
    $MeleeCombatController.attack(1.0)
```

### Checking Combat State

```gdscript
# Check if player can perform other actions
func can_dash() -> bool:
    return not $MeleeCombatController.is_attacking()

# Get combo progress
func update_combo_ui() -> void:
    var combo = $MeleeCombatController.get_combo_count()
    combo_label.text = str(combo) if combo > 0 else ""
```

### Responding to Combat Events

```gdscript
func _ready() -> void:
    var combat = $MeleeCombatController
    
    combat.attack_started.connect(func(num):
        $AnimationPlayer.play("attack_" + str(num))
        $AudioPlayer.play()
    )
    
    combat.attack_ended.connect(func():
        $AnimationPlayer.play("idle")
    )
    
    combat.combo_reset.connect(func():
        print("Combo dropped!")
    )
    
    combat.damage_received.connect(func(damage):
        health -= damage
        $AnimationPlayer.play("hurt")
    )
```

### Advanced: Custom Combo System

```gdscript
# Extend for 5-hit combo
extends MeleeCombatController

@export var attack_4_damage: float = 30.0
@export var attack_5_damage: float = 50.0

func _start_attack() -> void:
    # Override to support 5-hit combos
    _combo_count = (_combo_count % 5) + 1
    # ... rest of implementation
```

## Configuration

### MeleeCombatController Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `attack_1_duration` | float | 0.3 | Duration of first attack |
| `attack_2_duration` | float | 0.35 | Duration of second attack |
| `attack_3_duration` | float | 0.4 | Duration of third attack |
| `combo_window` | float | 0.5 | Time to continue combo after attack |
| `combo_reset_time` | float | 1.0 | Time before combo resets |
| `attack_1_damage` | float | 10.0 | Damage of first attack |
| `attack_2_damage` | float | 15.0 | Damage of second attack |
| `attack_3_damage` | float | 25.0 | Damage of third attack |
| `attack_1_knockback` | float | 200.0 | Knockback of first attack |
| `attack_2_knockback` | float | 300.0 | Knockback of second attack |
| `attack_3_knockback` | float | 500.0 | Knockback of third attack |
| `enabled` | bool | true | Whether combat is enabled |
| `attack_range` | float | 40.0 | Attack range from player center |

### Hitbox Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `damage` | float | 10.0 | Damage dealt by this hitbox |
| `knockback_force` | float | 300.0 | Knockback force applied |
| `active` | bool | true | Whether hitbox detects collisions |

### Hurtbox Parameters

| Parameter | Type | Default | Description |
|-----------|------|---------|-------------|
| `iframe_duration` | float | 0.5 | Invincibility frame duration |
| `weight` | float | 1.0 | Entity weight (affects knockback) |
| `vulnerable` | bool | true | Whether hurtbox can take damage |

## API Reference

### MeleeCombatController

#### Methods

- `attack(direction: float = 0.0) -> bool` - Execute a melee attack
- `can_attack() -> bool` - Check if attack is available
- `is_attacking() -> bool` - Check if currently attacking
- `get_combo_count() -> int` - Get current combo position (0-3)
- `reset_combo() -> void` - Manually reset combo chain
- `cancel_attack() -> void` - Immediately cancel current attack
- `set_enabled(value: bool) -> void` - Enable/disable combat
- `get_attack_direction() -> float` - Get current attack direction

#### Signals

- `attack_started(attack_number: int)` - Emitted when attack starts
- `attack_ended()` - Emitted when attack ends
- `combo_reset()` - Emitted when combo resets
- `damage_received(damage: float)` - Emitted when taking damage

### Hitbox

#### Methods

- `enable() -> void` - Enable hitbox collision detection
- `disable() -> void` - Disable hitbox collision detection
- `set_attack_direction(direction: float) -> void` - Set attack direction

#### Signals

- `hit_landed(hurtbox: Hurtbox)` - Emitted when hitting a target

### Hurtbox

#### Methods

- `take_damage(damage: float, knockback_force: float, knockback_direction: Vector2) -> void` - Receive damage
- `is_invincible() -> bool` - Check if i-frames are active
- `get_iframe_progress() -> float` - Get i-frame progress (0.0-1.0)
- `set_vulnerable(value: bool) -> void` - Manually set vulnerability

#### Signals

- `damage_taken(damage: float, knockback_force: float, knockback_direction: Vector2)` - Emitted when taking damage
- `iframe_started()` - Emitted when i-frames start
- `iframe_ended()` - Emitted when i-frames end

## Collision Layers

The system uses specific collision layers for proper detection:

- **Layer 3 (Binary: 100)**: Hitboxes
- **Layer 4 (Binary: 1000)**: Hurtboxes

These are automatically configured in the scripts.

## Controls

Default attack input:
- **Attack**: J or Z

## Integration with Existing Systems

### With Player Movement

The combat system is designed to work alongside movement systems without tight coupling:

```gdscript
extends Player2D  # Or your player controller

@onready var combat: MeleeCombatController = $MeleeCombatController

func _physics_process(delta: float) -> void:
    # Handle combat input
    if Input.is_action_just_pressed("attack"):
        combat.attack(get_facing_direction())
    
    # Normal movement processing
    super._physics_process(delta)
    
    # Optional: Reduce movement during attacks
    if combat.is_attacking():
        velocity.x *= 0.5
```

### With Animation System

```gdscript
func _ready() -> void:
    $Combat.attack_started.connect(func(num):
        $AnimationPlayer.play("attack_" + str(num))
    )
    
    $Combat.attack_ended.connect(func():
        # Return to movement-based animation
        if velocity.x != 0:
            $AnimationPlayer.play("run")
        else:
            $AnimationPlayer.play("idle")
    )
```

### With Health System

```gdscript
var health: float = 100.0
var max_health: float = 100.0

func _ready() -> void:
    $Hurtbox.damage_taken.connect(func(damage, _kb_force, _kb_dir):
        health -= damage
        if health <= 0:
            die()
    )
```

## Extending the System

### Adding New Attack Types

```gdscript
# Create specialized attack method
func special_attack() -> void:
    if not can_attack():
        return
    
    # Custom attack logic
    _combo_count = 0  # Don't count in combo
    _is_attacking = true
    _attack_timer = 0.6  # Longer duration
    
    # Activate hitbox with higher damage
    _activate_hitbox(0, 50.0, 800.0)
    
    attack_started.emit(0)
```

### Adding Aerial Attacks

```gdscript
# In your player script
func _physics_process(delta: float) -> void:
    if Input.is_action_just_pressed("attack"):
        if not is_on_floor():
            # Aerial attack
            $Combat.attack(get_facing_direction())
            velocity.y = 0  # Pause in air
        else:
            # Ground attack
            $Combat.attack(get_facing_direction())
```

### Adding Status Effects

```gdscript
# Extend Hurtbox
extends Hurtbox

var is_stunned: bool = false

func take_damage(damage: float, kb_force: float, kb_dir: Vector2) -> void:
    super.take_damage(damage, kb_force, kb_dir)
    
    # Add stun effect on heavy hits
    if damage >= 20.0:
        apply_stun(0.5)

func apply_stun(duration: float) -> void:
    is_stunned = true
    await get_tree().create_timer(duration).timeout
    is_stunned = false
```

## Troubleshooting

### Hitbox Not Detecting Hurtbox

1. Check collision layers are correct (Layer 3 for Hitbox, Layer 4 for Hurtbox)
2. Ensure CollisionShape2D children are present and properly sized
3. Verify hitbox is enabled during attack
4. Check that both nodes are in the scene tree

### Knockback Not Working

1. Ensure parent of Hurtbox is CharacterBody2D
2. Check that weight parameter is reasonable (0.1 to 10.0)
3. Verify knockback_force values are high enough
4. Make sure velocity is not being overridden elsewhere

### Combo Not Chaining

1. Check `combo_window` is long enough (default: 0.5s)
2. Verify attacks are completing before next input
3. Ensure `combo_reset_time` is appropriate
4. Check that attack queueing is working

### I-Frames Not Working

1. Verify `iframe_duration` is set > 0
2. Check that damage is only applied once per attack
3. Ensure i-frame timer is updating in _process()
4. Verify vulnerability flag is being checked

## Performance Considerations

- Hitboxes and Hurtboxes use Area2D which is efficient for this use case
- Disable hitboxes when not attacking to reduce collision checks
- Consider using object pooling for projectiles/effects
- Signal-based architecture minimizes polling overhead

## License

This combat system is open source and available for educational and commercial use.

## Credits

Built with ♥ using Godot Engine 4
Part of the ECHOES OF ASH project
