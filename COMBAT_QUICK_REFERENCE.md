# Melee Combat System - Quick Reference

Quick reference guide for the Melee Combat Controller system.

## Components Overview

### MeleeCombatController
Core combat system managing attacks and combos.

### Hitbox
Offensive collision detection (attacks hit enemies).

### Hurtbox
Defensive collision detection (character receives damage).

## Quick Setup

### 1. Basic Combat Setup
```gdscript
# In your player scene hierarchy:
Player (CharacterBody2D)
├── MeleeCombatController
│   └── Hitbox (Area2D)
│       └── CollisionShape2D
└── Hurtbox (Area2D)
    └── CollisionShape2D
```

### 2. Handle Attack Input
```gdscript
func _physics_process(delta: float) -> void:
    if Input.is_action_just_pressed("attack"):
        $MeleeCombatController.attack(get_facing_direction())
```

### 3. Connect Signals
```gdscript
func _ready() -> void:
    $MeleeCombatController.attack_started.connect(_on_attack_started)
    $MeleeCombatController.damage_received.connect(_on_damage_taken)
```

## Common Patterns

### Check Combat State
```gdscript
# Can the player attack?
if $Combat.can_attack():
    $Combat.attack()

# Is player attacking?
if $Combat.is_attacking():
    # Reduce movement speed
    velocity.x *= 0.5

# Get combo count
var combo = $Combat.get_combo_count()
```

### Attack with Direction
```gdscript
# Attack right
$Combat.attack(1.0)

# Attack left
$Combat.attack(-1.0)

# Auto-detect from movement
$Combat.attack()  # Uses parent's facing direction
```

### Handle Damage
```gdscript
func _ready() -> void:
    $Combat.damage_received.connect(func(damage):
        health -= damage
        if health <= 0:
            die()
    )
```

### Disable Combat (for cutscenes, etc.)
```gdscript
# Disable
$Combat.set_enabled(false)

# Enable
$Combat.set_enabled(true)
```

### Cancel Attack
```gdscript
# Immediately stop current attack
$Combat.cancel_attack()
```

### Reset Combo
```gdscript
# Manually reset combo to 0
$Combat.reset_combo()
```

## Key Parameters

### Combat Controller
- `attack_X_duration`: How long each attack lasts (0.3-0.4s)
- `combo_window`: Time to continue combo (0.5s)
- `combo_reset_time`: Time before combo resets (1.0s)
- `attack_X_damage`: Damage per hit (10-25)
- `attack_X_knockback`: Knockback force (200-500)
- `attack_range`: Distance from player (40px)

### Hitbox
- `damage`: Damage dealt (10.0)
- `knockback_force`: Base knockback (300.0)
- `active`: Whether hitbox is enabled (true)

### Hurtbox
- `iframe_duration`: Invincibility time (0.5s)
- `weight`: Affects knockback (1.0 = normal)
- `vulnerable`: Can take damage (true)

## Signals

### MeleeCombatController
```gdscript
signal attack_started(attack_number: int)  # 1, 2, or 3
signal attack_ended()
signal combo_reset()
signal damage_received(damage: float)
```

### Hitbox
```gdscript
signal hit_landed(hurtbox: Hurtbox)
```

### Hurtbox
```gdscript
signal damage_taken(damage: float, knockback_force: float, knockback_direction: Vector2)
signal iframe_started()
signal iframe_ended()
```

## API Reference

### MeleeCombatController Methods
```gdscript
attack(direction: float = 0.0) -> bool
can_attack() -> bool
is_attacking() -> bool
get_combo_count() -> int
reset_combo() -> void
cancel_attack() -> void
set_enabled(value: bool) -> void
get_attack_direction() -> float
```

### Hitbox Methods
```gdscript
enable() -> void
disable() -> void
set_attack_direction(direction: float) -> void
```

### Hurtbox Methods
```gdscript
take_damage(damage: float, knockback_force: float, knockback_direction: Vector2) -> void
is_invincible() -> bool
get_iframe_progress() -> float
set_vulnerable(value: bool) -> void
```

## Collision Layers

The system automatically configures:
- **Layer 3**: Hitboxes (offensive)
- **Layer 4**: Hurtboxes (defensive)

No manual layer configuration needed!

## Common Issues

### Hitbox not hitting Hurtbox
- Ensure CollisionShape2D children exist
- Check shapes overlap during attack
- Verify hitbox is enabled

### No knockback
- Parent must be CharacterBody2D
- Check weight isn't too high
- Verify knockback_force > 0

### Combo not chaining
- Increase combo_window
- Attack within window after previous attack
- Check combo_reset_time isn't too short

### Taking damage during i-frames
- Verify iframe_duration > 0
- Check multiple hitboxes aren't hitting simultaneously
- Ensure Hurtbox._process() is running

## Tips

### Visual Feedback
```gdscript
func _on_attack_started(num: int) -> void:
    $AnimationPlayer.play("attack_" + str(num))
    $AttackVFX.show()
    $AudioPlayer.play()
```

### Combo Display
```gdscript
func _process(_delta: float) -> void:
    var combo = $Combat.get_combo_count()
    $ComboLabel.text = str(combo) + " HIT!" if combo > 0 else ""
```

### Movement During Attacks
```gdscript
func _physics_process(delta: float) -> void:
    # Allow reduced movement during attacks
    if $Combat.is_attacking():
        velocity.x *= 0.5
```

### Weight-Based Enemies
```gdscript
# Light enemy (more knockback)
$Hurtbox.weight = 0.5

# Heavy enemy (less knockback)
$Hurtbox.weight = 2.0

# Boss (minimal knockback)
$Hurtbox.weight = 5.0
```

## Integration Examples

### With Animation
```gdscript
var combat: MeleeCombatController

func _ready() -> void:
    combat.attack_started.connect(func(num):
        match num:
            1: $Anim.play("attack_1")
            2: $Anim.play("attack_2")
            3: $Anim.play("attack_3_finisher")
    )
```

### With Health System
```gdscript
var health: float = 100.0
var max_health: float = 100.0

func _ready() -> void:
    $Hurtbox.damage_taken.connect(func(dmg, _kf, _kd):
        health = max(0, health - dmg)
        update_health_bar()
        if health <= 0:
            die()
    )
```

### With Enemy AI
```gdscript
func _ready() -> void:
    $Hurtbox.damage_taken.connect(func(_d, _kf, _kd):
        # React to being hit
        state_machine.set_state("hurt")
        # Face the attacker
        face_player()
        # Counter-attack
        await get_tree().create_timer(0.3).timeout
        perform_counter_attack()
    )
```

## Performance Tips

1. Disable hitboxes when not attacking
2. Use appropriate collision shape sizes
3. Limit hitbox active duration
4. Pool visual effects
5. Use signals instead of polling state

## Extension Ideas

### Add Special Attacks
```gdscript
func heavy_attack() -> void:
    if $Combat.can_attack():
        $Combat.attack(get_facing_direction())
        # Override with custom damage/knockback
        $Combat/Hitbox.damage = 30.0
        $Combat/Hitbox.knockback_force = 1000.0
```

### Add Aerial Combat
```gdscript
func _physics_process(delta: float) -> void:
    if Input.is_action_just_pressed("attack"):
        if not is_on_floor():
            perform_aerial_attack()
        else:
            $Combat.attack(get_facing_direction())
```

### Add Charge Attacks
```gdscript
var charge_time: float = 0.0

func _process(delta: float) -> void:
    if Input.is_action_pressed("attack"):
        charge_time += delta
    
    if Input.is_action_just_released("attack"):
        var power = min(charge_time / 2.0, 1.0)
        perform_charged_attack(power)
        charge_time = 0.0
```

## Need Help?

- Check `MELEE_COMBAT_SYSTEM.md` for full documentation
- See `combat_integration_example.gd` for complete example
- Run `test_combat_system.gd` to verify setup
- Review signals for debugging

## Summary

1. Add MeleeCombatController + Hitbox to player
2. Add Hurtbox to characters that can be hit
3. Call `attack()` on input
4. Connect signals for feedback
5. Configure parameters in inspector
6. Test and iterate!
