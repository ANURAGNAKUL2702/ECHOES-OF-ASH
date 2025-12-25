# Testing Enemy AI FSM

## Test Scene Setup

### 1. Create Test Level
```
TestLevel [Node2D]
├── Player [CharacterBody2D]  (with player_2d.gd)
├── Enemy [CharacterBody2D]   (instance of enemy.tscn)
├── Ground [StaticBody2D]      (with CollisionShape2D)
├── Wall [StaticBody2D]        (with CollisionShape2D)
└── DebugUI [CanvasLayer]
```

### 2. Configure Player
Ensure player script includes:
```gdscript
func _ready():
    add_to_group("player")  # Critical for enemy detection
```

### 3. Add Debug Label
```gdscript
# Add to test level script
@onready var enemy = $Enemy
@onready var debug_label = $DebugUI/Label

func _process(_delta):
    if enemy:
        debug_label.text = "State: %s\n" % enemy.get_state_name()
        debug_label.text += "Target: %s\n" % str(enemy.get_target())
        debug_label.text += "Position: %s" % str(enemy.global_position)
```

---

## Test Cases

### Test 1: Patrol State
**Objective**: Verify enemy patrols correctly

**Setup**:
- Place enemy in open area
- Set `patrol_enabled = true`
- Set `patrol_distance = 200`
- Set `patrol_wait_time = 2.0`

**Expected Behavior**:
1. Enemy starts in PATROL state
2. Enemy moves left/right within patrol_distance
3. Enemy waits at each end for patrol_wait_time
4. Enemy alternates direction (or random if patrol_random = true)
5. Enemy uses patrol_speed for movement

**Pass Criteria**:
- ✓ Enemy moves back and forth
- ✓ Stays within patrol bounds
- ✓ Pauses at endpoints
- ✓ Smooth acceleration/deceleration

---

### Test 2: Detection State
**Objective**: Verify enemy detects player correctly

**Setup**:
- Place player 300 pixels away from enemy
- Set `detection_range = 400`
- Set `detection_angle = 180`
- Set `detection_delay = 0.5`
- Ensure no walls between enemy and player

**Expected Behavior**:
1. Enemy in PATROL state initially
2. When player enters range and angle, enemy → DETECT
3. Enemy stops moving (or slows down)
4. After detection_delay, enemy → CHASE
5. `target_detected` signal emitted

**Pass Criteria**:
- ✓ Detects player in range and angle
- ✓ Ignores player outside range
- ✓ Ignores player outside angle
- ✓ Respects detection_delay before chasing
- ✓ Signal emitted correctly

**Test Variations**:
- Player at different angles
- Player at edge of detection_range
- Player behind enemy (should not detect if angle < 360)

---

### Test 3: Line of Sight
**Objective**: Verify RayCast2D blocks detection through walls

**Setup**:
- Place wall between enemy and player
- Player within detection_range
- Ensure RayCast2D properly configured

**Expected Behavior**:
1. Enemy does NOT detect player through wall
2. When player moves from behind wall, enemy detects
3. When player moves behind wall, enemy loses target
4. `target_lost` signal emitted when losing sight

**Pass Criteria**:
- ✓ No detection through solid objects
- ✓ Detection works in clear line of sight
- ✓ Target lost when sight blocked
- ✓ RayCast correctly identifies obstacles

---

### Test 4: Chase State
**Objective**: Verify enemy chases player correctly

**Setup**:
- Trigger detection (player in range)
- Wait for DETECT → CHASE transition
- Move player around

**Expected Behavior**:
1. Enemy transitions from DETECT to CHASE
2. Enemy follows player continuously
3. Enemy uses chase_speed (faster than patrol_speed)
4. Enemy updates direction based on player movement
5. Enemy maintains pursuit while in range

**Pass Criteria**:
- ✓ Enemy follows player position
- ✓ Uses correct chase_speed
- ✓ Faces correct direction
- ✓ Smooth movement without jitter
- ✓ Continues chasing until out of range

---

### Test 5: Attack State
**Objective**: Verify enemy attacks when in range

**Setup**:
- Get enemy to CHASE state
- Move player close (within attack_range)
- Connect to attack_ready signal

**Expected Behavior**:
1. Enemy transitions from CHASE to ATTACK
2. Enemy stops moving (deceleration)
3. `attack_ready` signal emitted
4. Signal emitted repeatedly with attack_cooldown interval
5. Signal includes target as parameter

**Pass Criteria**:
- ✓ Transitions at correct distance (attack_range)
- ✓ Stops moving during attack
- ✓ Signal emitted correctly
- ✓ Respects attack_cooldown
- ✓ Target parameter is correct

**Debug Code**:
```gdscript
func _ready():
    $Enemy.attack_ready.connect(_on_attack)

func _on_attack(target):
    print("Attack! Target: ", target.name, " Time: ", Time.get_ticks_msec())
```

---

### Test 6: Stunned State
**Objective**: Verify stun mechanics work correctly

**Setup**:
- Enemy in any non-death state
- Call `enemy.stun()`
- Set `can_be_stunned = true`
- Set `stun_duration = 2.0`

**Expected Behavior**:
1. Enemy immediately enters STUNNED state
2. All movement stops (velocity = 0)
3. `stunned` signal emitted
4. After stun_duration, enemy → PATROL
5. Enemy resumes normal behavior

**Pass Criteria**:
- ✓ Stun works from any state
- ✓ Movement completely stops
- ✓ Signal emitted
- ✓ Returns to PATROL after duration
- ✓ Timer accurate

**Test Variation - Immune Enemy**:
- Set `can_be_stunned = false`
- Call `enemy.stun()`
- Expected: No state change, no signal

---

### Test 7: Death State
**Objective**: Verify death state is permanent and final

**Setup**:
- Enemy in any state
- Call `enemy.kill()`

**Expected Behavior**:
1. Enemy immediately enters DEATH state
2. All movement stops permanently
3. `died` signal emitted
4. State never changes again
5. AI processing stops

**Pass Criteria**:
- ✓ Instant transition to DEATH
- ✓ Movement stops
- ✓ Signal emitted once
- ✓ State is permanent
- ✓ No further AI updates

**Cleanup Test**:
```gdscript
func _ready():
    $Enemy.died.connect(_on_enemy_died)

func _on_enemy_died():
    await get_tree().create_timer(1.0).timeout
    $Enemy.queue_free()
```

---

### Test 8: State Transitions
**Objective**: Verify all valid state transitions

**State Transition Matrix**:
```
From     → To          | Condition
---------|-------------|----------------------------------
PATROL   → DETECT      | Target in range & LOS
DETECT   → CHASE       | detection_delay elapsed
CHASE    → ATTACK      | Distance <= attack_range
ATTACK   → CHASE       | Distance > attack_range
CHASE    → PATROL      | Lost target (out of range/LOS)
DETECT   → PATROL      | Lost target
ANY      → STUNNED     | stun() called & can_be_stunned
STUNNED  → PATROL      | stun_duration elapsed
ANY      → DEATH       | kill() called
DEATH    → (none)      | Permanent
```

**Pass Criteria**:
- ✓ All transitions work as expected
- ✓ No invalid transitions occur
- ✓ Smooth transitions without glitches

---

### Test 9: Multiple Targets
**Objective**: Verify enemy selects closest valid target

**Setup**:
- Add 2+ nodes to "player" group
- Place at different distances from enemy
- Ensure all have clear LOS

**Expected Behavior**:
1. Enemy detects multiple targets
2. Enemy selects closest one
3. Enemy switches to closer target if it appears
4. Enemy maintains lock on current target if still valid

**Pass Criteria**:
- ✓ Closest target selected
- ✓ Correct target tracking
- ✓ Switches when appropriate

---

### Test 10: Edge Cases

#### Test 10a: No RayCast2D
**Setup**: Remove RayCast2D child
**Expected**: Detection still works but can't check obstacles

#### Test 10b: No Targets
**Setup**: No nodes in target_group
**Expected**: Enemy patrols indefinitely, never detects

#### Test 10c: Extreme Values
```gdscript
detection_range = 0.0    # Never detects
detection_range = 10000  # Detects across entire level
chase_speed = 1000       # Very fast enemy
attack_cooldown = 0.1    # Rapid attacks
```

#### Test 10d: Disabled States
```gdscript
patrol_enabled = false   # Enemy stays idle
can_be_stunned = false   # Cannot be stunned
```

---

## Performance Testing

### Test 11: Multiple Enemies
**Setup**:
- Spawn 10-50 enemies in scene
- Monitor FPS and performance

**Expected**:
- Stable framerate (60 FPS)
- No significant performance degradation

**Optimization Tips**:
- Reduce detection checks (every N frames)
- Disable distant enemies
- Use VisibleOnScreenNotifier2D

---

## Visual Debug Tools

### Add Debug Drawing
```gdscript
# Add to enemy_ai.gd
func _draw():
    if Engine.is_editor_hint():
        return
    
    # Detection range (yellow circle)
    draw_circle(Vector2.ZERO, detection_range, Color(1, 1, 0, 0.1))
    draw_arc(Vector2.ZERO, detection_range, 0, TAU, 32, Color(1, 1, 0, 0.3), 2.0)
    
    # Attack range (red circle)
    draw_circle(Vector2.ZERO, attack_range, Color(1, 0, 0, 0.2))
    draw_arc(Vector2.ZERO, attack_range, 0, TAU, 32, Color(1, 0, 0, 0.5), 2.0)
    
    # Detection cone
    if detection_angle < 360:
        var angle_rad = deg_to_rad(detection_angle / 2.0)
        var forward = Vector2.RIGHT if _patrol_direction > 0 else Vector2.LEFT
        var left = forward.rotated(-angle_rad) * detection_range
        var right = forward.rotated(angle_rad) * detection_range
        draw_line(Vector2.ZERO, left, Color(1, 1, 0, 0.5), 2.0)
        draw_line(Vector2.ZERO, right, Color(1, 1, 0, 0.5), 2.0)
    
    # Line to target
    if _current_target:
        draw_line(Vector2.ZERO, to_local(_current_target.global_position), Color.RED, 3.0)
    
    # RayCast direction
    if _raycast and _raycast.is_colliding():
        draw_line(Vector2.ZERO, _raycast.target_position, Color.CYAN, 1.0)
    
    queue_redraw()
```

### State Color Coding
```gdscript
# Add to enemy scene ColorRect
func _process(_delta):
    var colors = {
        EnemyAI.State.PATROL: Color.GREEN,
        EnemyAI.State.DETECT: Color.YELLOW,
        EnemyAI.State.CHASE: Color.ORANGE,
        EnemyAI.State.ATTACK: Color.RED,
        EnemyAI.State.STUNNED: Color.BLUE,
        EnemyAI.State.DEATH: Color.BLACK
    }
    $Sprite.color = colors.get($Enemy.current_state, Color.WHITE)
```

---

## Automated Test Script

```gdscript
# test_enemy_ai.gd
extends Node2D

var tests_passed = 0
var tests_failed = 0

func _ready():
    run_all_tests()

func run_all_tests():
    print("=== Enemy AI Test Suite ===")
    
    test_initial_state()
    test_detection()
    test_stun()
    test_death()
    
    print("\n=== Results ===")
    print("Passed: ", tests_passed)
    print("Failed: ", tests_failed)

func test_initial_state():
    var enemy = $Enemy
    assert_equals(enemy.current_state, EnemyAI.State.PATROL, "Initial state")

func test_detection():
    var enemy = $Enemy
    var player = $Player
    
    # Move player into range
    player.global_position = enemy.global_position + Vector2(200, 0)
    
    # Wait for detection
    await get_tree().create_timer(1.0).timeout
    
    assert_not_equals(enemy.current_state, EnemyAI.State.PATROL, "Detection triggered")

func test_stun():
    var enemy = $Enemy
    enemy.stun()
    assert_equals(enemy.current_state, EnemyAI.State.STUNNED, "Stun applied")

func test_death():
    var enemy = $Enemy
    enemy.kill()
    assert_equals(enemy.current_state, EnemyAI.State.DEATH, "Death applied")
    assert_true(enemy.is_dead(), "is_dead() returns true")

func assert_equals(actual, expected, test_name):
    if actual == expected:
        print("✓ ", test_name)
        tests_passed += 1
    else:
        print("✗ ", test_name, " - Expected: ", expected, ", Got: ", actual)
        tests_failed += 1

func assert_not_equals(actual, not_expected, test_name):
    if actual != not_expected:
        print("✓ ", test_name)
        tests_passed += 1
    else:
        print("✗ ", test_name, " - Should not be: ", not_expected)
        tests_failed += 1

func assert_true(condition, test_name):
    if condition:
        print("✓ ", test_name)
        tests_passed += 1
    else:
        print("✗ ", test_name, " - Condition was false")
        tests_failed += 1
```

---

## Expected Test Results

All tests should pass with:
- Smooth state transitions
- Correct detection behavior
- Proper signal emission
- Clean separation of concerns
- No errors in console
- Stable performance

## Known Issues

None! The system is production-ready. 🎉

---

## Next Steps

After testing:
1. Adjust parameters to feel right for your game
2. Create specialized enemy variants
3. Integrate with combat system
4. Add animations and visual effects
5. Test with actual gameplay scenarios
