# Enemy AI Module - Quick Reference

## Quick Setup (30 seconds)

### 1. Add Enemy to Scene
```
Scene Tree:
├── YourLevel
│   └── Enemy [CharacterBody2D]  (instance enemy.tscn)
│       ├── CollisionShape2D
│       ├── RayCast2D
│       └── Sprite
```

### 2. Configure Target
```gdscript
# In player script:
func _ready():
    add_to_group("player")  # Enemy will detect this
```

### 3. Connect Signals
```gdscript
func _ready():
    $Enemy.attack_ready.connect(_on_enemy_attack)

func _on_enemy_attack(target: Node2D):
    target.take_damage(10)  # Your combat logic here
```

Done! Enemy will patrol, detect, chase, and attack.

---

## Common Parameters

### Detection (Inspector)
```
detection_range = 400      # How far enemy can see
detection_angle = 180      # Field of view (degrees)
target_group = "player"    # What to look for
```

### Speed (Inspector)
```
patrol_speed = 100         # Speed while patrolling
chase_speed = 200          # Speed while chasing
```

### Patrol (Inspector)
```
patrol_enabled = true      # Enable/disable patrol
patrol_distance = 200      # How far to patrol
patrol_wait_time = 2.0     # Wait time at ends
```

### Combat (Inspector)
```
attack_range = 50          # How close to attack
attack_cooldown = 1.5      # Time between attacks
can_be_stunned = true      # Can be stunned?
stun_duration = 2.0        # Stun length
```

---

## Signals Reference

### All Available Signals
```gdscript
signal target_detected(target: Node2D)  # Spotted a target
signal target_lost                       # Lost sight of target
signal attack_ready(target: Node2D)     # Ready to attack
signal stunned                           # Got stunned
signal died                              # Was killed
```

### Example Usage
```gdscript
func _ready():
    var enemy = $Enemy
    
    # Play sound when player detected
    enemy.target_detected.connect(func(t): $AlertSound.play())
    
    # Handle attacks
    enemy.attack_ready.connect(_deal_damage)
    
    # Handle death
    enemy.died.connect(func(): 
        $DeathAnimation.play()
        await $DeathAnimation.finished
        queue_free()
    )
```

---

## Public Methods

### Control Methods
```gdscript
enemy.stun()                    # Stun the enemy
enemy.kill()                    # Kill the enemy
enemy.set_patrol_bounds(pos, dist)  # Set custom patrol
```

### Query Methods
```gdscript
enemy.get_state_name()          # Returns: "PATROL", "CHASE", etc.
enemy.is_dead()                 # Returns: true/false
enemy.get_target()              # Returns: current target or null
```

---

## States Overview

```
PATROL → DETECT → CHASE → ATTACK
  ↕        ↕        ↕        ↕
STUNNED ← ← ← ← ← ← ← ← ← ← ←
  ↓
DEATH (permanent)
```

### State Behaviors
- **PATROL**: Walks back and forth, idle, or custom path
- **DETECT**: Sees target, waiting before chase
- **CHASE**: Actively following target
- **ATTACK**: In range, attacking at intervals
- **STUNNED**: Temporarily disabled, returns to patrol
- **DEATH**: Disabled permanently

---

## Common Patterns

### Pattern 1: Basic Enemy
```gdscript
# No script needed - just use enemy.tscn!
# Connect signals from parent scene
```

### Pattern 2: Custom Enemy Type
```gdscript
extends EnemyAI

func _ready():
    super._ready()
    chase_speed = 300.0  # Make it faster
    attack_cooldown = 0.5  # Attack more frequently
```

### Pattern 3: Boss Enemy
```gdscript
extends EnemyAI

func _ready():
    super._ready()
    detection_range = 1000.0  # Sees everything
    can_be_stunned = false    # Immune to stun
    patrol_enabled = false    # Doesn't patrol
```

### Pattern 4: Ranged Enemy
```gdscript
extends EnemyAI

func _ready():
    super._ready()
    attack_range = 300.0  # Attacks from distance
    
    attack_ready.connect(_shoot_projectile)

func _shoot_projectile(target: Node2D):
    var projectile = ProjectileScene.instantiate()
    projectile.target = target
    get_parent().add_child(projectile)
```

---

## Integration with Combat

### Example: Simple Health System
```gdscript
# In your combat manager or level script
func _ready():
    $Enemy.attack_ready.connect(_enemy_attack)

func _enemy_attack(target: Node2D):
    if target.has_method("take_damage"):
        target.take_damage(10)
    
    # Visual feedback
    $HitParticles.global_position = target.global_position
    $HitParticles.emitting = true
    $HitSound.play()
```

### Example: Stun on Heavy Hit
```gdscript
func player_attacks_enemy(damage: int):
    enemy_health -= damage
    
    # Stun on heavy attacks
    if damage >= 20:
        $Enemy.stun()
    
    # Kill if health depleted
    if enemy_health <= 0:
        $Enemy.kill()
```

---

## Debugging Tips

### Show Current State
```gdscript
# Add Label node to enemy
@onready var label = $StateLabel

func _process(_delta):
    label.text = enemy.get_state_name()
```

### Visualize Detection Range
```gdscript
func _draw():
    # Yellow circle = detection range
    draw_circle(Vector2.ZERO, detection_range, Color(1, 1, 0, 0.1))
    
    # Red circle = attack range
    draw_circle(Vector2.ZERO, attack_range, Color(1, 0, 0, 0.2))
    
    # Line to target
    if get_target():
        draw_line(Vector2.ZERO, 
                  to_local(get_target().global_position), 
                  Color.RED, 2.0)
    
    queue_redraw()  # Update every frame
```

### Print State Changes
```gdscript
func _ready():
    # Monitor all signals
    $Enemy.target_detected.connect(func(t): print("Detected: ", t))
    $Enemy.target_lost.connect(func(): print("Lost target"))
    $Enemy.stunned.connect(func(): print("Stunned!"))
    $Enemy.died.connect(func(): print("Dead!"))
```

---

## Troubleshooting

### Enemy doesn't detect player
1. ✓ Player is in "player" group? `add_to_group("player")`
2. ✓ RayCast2D exists as child of enemy?
3. ✓ RayCast2D collision_mask set correctly?
4. ✓ Player within detection_range?

### Enemy walks through walls
1. ✓ Enemy has CollisionShape2D?
2. ✓ Walls on correct collision layer?
3. ✓ Enemy collision_mask includes wall layer?

### Enemy doesn't attack
1. ✓ Connected to attack_ready signal?
2. ✓ Target within attack_range?
3. ✓ Combat logic implemented in signal handler?

### Enemy jitters or stutters
1. ✓ acceleration/deceleration values reasonable?
2. ✓ patrol_distance not too small?
3. ✓ Project running at stable framerate?

---

## Performance Tips

### For Many Enemies
```gdscript
# Reduce detection frequency
var detection_counter = 0

func physics_update_state():
    detection_counter += 1
    if detection_counter % 3 == 0:  # Check every 3 frames
        super.physics_update_state()
```

### For Large Levels
```gdscript
# Disable enemies far from player
func _process(_delta):
    var distance_to_player = global_position.distance_to(player.global_position)
    set_physics_process(distance_to_player < 800)
```

---

## Recipe: Multiple Enemy Types

### Fast Scout
```
patrol_speed = 150
chase_speed = 300
attack_range = 40
attack_cooldown = 0.8
```

### Heavy Brute  
```
patrol_speed = 50
chase_speed = 100
attack_range = 60
attack_cooldown = 2.5
can_be_stunned = false
```

### Stationary Turret
```
patrol_enabled = false
detection_angle = 360
detection_range = 500
attack_range = 400
```

### Ambush Enemy
```
patrol_enabled = false
detection_delay = 0.0
chase_speed = 350
```

---

## Full Example: Complete Enemy Setup

```gdscript
# level.gd
extends Node2D

@onready var enemy = $Enemy
@onready var player = $Player

func _ready():
    # Make player detectable
    player.add_to_group("player")
    
    # Connect enemy signals
    enemy.target_detected.connect(_on_enemy_detected)
    enemy.attack_ready.connect(_on_enemy_attack)
    enemy.died.connect(_on_enemy_died)

func _on_enemy_detected(target):
    print("Enemy spotted the player!")
    $AlertSound.play()

func _on_enemy_attack(target):
    if target.has_method("take_damage"):
        target.take_damage(10)
    $AttackSound.play()

func _on_enemy_died():
    $DeathSound.play()
    await get_tree().create_timer(1.0).timeout
    enemy.queue_free()
```

---

## See Also

- `ENEMY_AI_IMPLEMENTATION_SUMMARY.md` - Full documentation
- `scripts/enemy_integration_example.gd` - Example integration
- `scenes/enemy.tscn` - Example enemy scene
- `scripts/enemy_ai.gd` - Source code with comments
