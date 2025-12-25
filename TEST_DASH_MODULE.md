# Testing the Dash Module

This document provides guidance on testing the `DashModule` implementation.

## Manual Testing in Godot Editor

### Setup

1. Open the project in Godot 4.2+
2. Open the scene `scenes/player.tscn`
3. Add a `DashModule` node as a child of the Player node:
   - Right-click on the Player node
   - Select "Add Child Node"
   - Search for "Node" and add it
   - In the Inspector, click the script icon and attach `dash_module.gd`
   - The node should automatically be recognized as `DashModule` class
4. Configure the dash parameters in the Inspector (or use defaults)

### Basic Integration Test

Create a simple test script to integrate with the player:

```gdscript
# Add this to your Player2D script or create a new script

@export var dash_module: DashModule

func _ready():
    # Find dash module if not assigned
    if not dash_module:
        dash_module = get_node_or_null("DashModule")
    
    # Connect signals for testing
    if dash_module:
        dash_module.dash_started.connect(_on_dash_started)
        dash_module.dash_ended.connect(_on_dash_ended)
        dash_module.dash_ready.connect(_on_dash_ready)

func _process(_delta):
    # Test dash with Shift key (add to project input map)
    if Input.is_action_just_pressed("dash"):
        test_dash()

func test_dash():
    if not dash_module:
        print("ERROR: No DashModule found!")
        return
    
    if not dash_module.can_dash():
        print("Dash on cooldown or disabled")
        return
    
    # Get direction from current movement
    var direction = sign(velocity.x) if velocity.x != 0 else 1.0
    
    # Execute dash
    var success = dash_module.dash(self, direction)
    print("Dash executed: ", success)

func _on_dash_started():
    print("=== DASH STARTED ===")

func _on_dash_ended():
    print("=== DASH ENDED ===")

func _on_dash_ready():
    print("=== DASH READY ===")
```

### Adding Dash Input Action

1. Open Project → Project Settings → Input Map
2. Add a new action called "dash"
3. Assign it to a key (e.g., Shift, Space, or a mouse button)
4. Click "Add" and "Close"

## Test Cases

### Test 1: Basic Dash Execution
**Objective**: Verify that dash executes correctly

**Steps**:
1. Run the game (F5)
2. Move the player left or right
3. Press the dash key
4. Observe player movement

**Expected Result**:
- Player should burst forward in the direction of movement
- Console should print "=== DASH STARTED ==="
- Movement should be noticeably faster than normal
- After ~0.2 seconds, console should print "=== DASH ENDED ==="

### Test 2: Cooldown System
**Objective**: Verify cooldown prevents consecutive dashes

**Steps**:
1. Run the game
2. Execute a dash
3. Immediately try to dash again (within 1 second)
4. Wait 1 second
5. Try to dash again

**Expected Result**:
- First dash should succeed
- Second dash (immediate) should fail with "Dash on cooldown or disabled"
- After 1 second, console should print "=== DASH READY ==="
- Third dash should succeed

### Test 3: Direction Detection
**Objective**: Verify dash direction is correctly determined

**Steps**:
1. Run the game
2. Stand still and press dash
3. Move right and press dash
4. Move left and press dash

**Expected Result**:
- Standing still: Dash right (default direction)
- Moving right: Dash right
- Moving left: Dash left

### Test 4: Enable/Disable Toggle
**Objective**: Verify dash can be enabled/disabled

**Steps**:
1. Run the game
2. In the Inspector, set DashModule's `enabled` to `false`
3. Try to dash
4. Set `enabled` to `true`
5. Try to dash

**Expected Result**:
- When disabled: Dash fails with "Dash on cooldown or disabled"
- When enabled: Dash succeeds

### Test 5: Invincibility Frames
**Objective**: Verify i-frames are active during dash

**Steps**:
1. Add this debug code to your player script:
```gdscript
func _process(_delta):
    if dash_module and dash_module.is_invincible():
        modulate = Color(1, 1, 0, 0.7)  # Yellow tint
    else:
        modulate = Color(1, 1, 1, 1)  # Normal
```
2. Run the game
3. Execute a dash
4. Observe player appearance

**Expected Result**:
- During dash (first ~0.15 seconds), player should have yellow tint
- After i-frames end, player should return to normal color
- `is_invincible()` should return `true` during tint

### Test 6: Query Methods
**Objective**: Verify all query methods work correctly

**Steps**:
Add this debug display to your player script:
```gdscript
func _process(_delta):
    if dash_module:
        var info = "Can Dash: %s | Dashing: %s | Invincible: %s | Cooldown: %.2f" % [
            dash_module.can_dash(),
            dash_module.is_dashing(),
            dash_module.is_invincible(),
            dash_module.get_cooldown_progress()
        ]
        # Display on screen with Label node or print
        print(info)
```

**Expected Result**:
- Before dash: `Can Dash: true | Dashing: false | Invincible: false | Cooldown: 0.00`
- During dash: `Can Dash: false | Dashing: true | Invincible: true | Cooldown: 0.00`
- After dash: `Can Dash: false | Dashing: false | Invincible: false | Cooldown: 1.00→0.00`
- After cooldown: `Can Dash: true | Dashing: false | Invincible: false | Cooldown: 0.00`

### Test 7: Parameter Adjustment
**Objective**: Verify parameters can be adjusted in real-time

**Steps**:
1. Run the game
2. Pause (or use remote inspector)
3. Adjust parameters in Inspector:
   - `dash_speed`: 1000
   - `dash_duration`: 0.5
   - `dash_cooldown`: 2.0
   - `iframe_duration`: 0.3
4. Unpause and test dash

**Expected Result**:
- Dash should be faster (speed 1000)
- Dash should last longer (0.5 seconds)
- Cooldown should be longer (2 seconds)
- I-frames should last longer (0.3 seconds)

### Test 8: Multiple Dashes
**Objective**: Verify module handles repeated use correctly

**Steps**:
1. Run the game
2. Execute 10 consecutive dashes (waiting for cooldown each time)
3. Observe consistency

**Expected Result**:
- All dashes should work consistently
- No crashes or errors
- Timers should reset properly between dashes
- Signals should fire correctly each time

## Debug Visualization

### Visual Cooldown Indicator
Add a visual indicator to see cooldown in real-time:

```gdscript
# Add a ColorRect or ProgressBar to your player scene
# Name it "CooldownIndicator"

func _process(_delta):
    if dash_module and has_node("CooldownIndicator"):
        var progress = dash_module.get_cooldown_progress()
        $CooldownIndicator.value = (1.0 - progress) * 100
        # Or for ColorRect:
        # $CooldownIndicator.modulate.a = progress
```

### Dash Trail Effect
Create a visual dash trail for testing:

```gdscript
func _on_dash_started():
    # Create trail using particles or sprite copies
    for i in range(5):
        var ghost = Sprite2D.new()
        ghost.texture = $Sprite2D.texture
        ghost.modulate = Color(1, 1, 1, 0.3)
        get_parent().add_child(ghost)
        ghost.global_position = global_position
        
        # Fade out and delete
        var tween = create_tween()
        tween.tween_property(ghost, "modulate:a", 0.0, 0.5)
        tween.tween_callback(ghost.queue_free)
```

### State Display
Show dash state on screen:

```gdscript
# Add a Label node to your scene called "DebugLabel"

func _process(_delta):
    if dash_module and has_node("DebugLabel"):
        $DebugLabel.text = """
Dash Module State:
- Can Dash: %s
- Is Dashing: %s
- Is Invincible: %s
- Direction: %s
- Cooldown: %.2f%%
- Time Until Ready: %.2fs
        """ % [
            dash_module.can_dash(),
            dash_module.is_dashing(),
            dash_module.is_invincible(),
            dash_module.get_dash_direction(),
            dash_module.get_cooldown_progress() * 100,
            dash_module.get_time_until_ready()
        ]
```

## Automated Testing Notes

While Godot doesn't have a built-in unit testing framework in this project, you can create test scenes:

### Test Scene Structure
```
test_dash.tscn
├── Player (CharacterBody2D)
│   ├── CollisionShape2D
│   ├── Sprite2D
│   ├── DashModule
│   └── TestScript (test_dash.gd)
└── Ground (StaticBody2D)
    └── CollisionShape2D
```

### Test Script Template
```gdscript
extends Node

var dash_module: DashModule
var player: CharacterBody2D
var test_results: Array[String] = []

func _ready():
    player = get_parent() as CharacterBody2D
    dash_module = player.get_node("DashModule")
    
    # Run tests after a short delay
    await get_tree().create_timer(0.5).timeout
    run_tests()

func run_tests():
    print("=== STARTING DASH MODULE TESTS ===")
    
    test_initial_state()
    test_dash_execution()
    test_cooldown()
    test_enable_disable()
    
    print("=== TEST RESULTS ===")
    for result in test_results:
        print(result)
    
    print("=== TESTS COMPLETE ===")

func test_initial_state():
    var passed = dash_module.can_dash() and not dash_module.is_dashing()
    test_results.append("Initial State: %s" % ("PASS" if passed else "FAIL"))

func test_dash_execution():
    var success = dash_module.dash(player, 1.0)
    var passed = success and dash_module.is_dashing()
    test_results.append("Dash Execution: %s" % ("PASS" if passed else "FAIL"))

func test_cooldown():
    dash_module.dash(player, 1.0)
    await get_tree().create_timer(0.3).timeout
    var on_cooldown = not dash_module.can_dash()
    await get_tree().create_timer(1.0).timeout
    var cooldown_ended = dash_module.can_dash()
    var passed = on_cooldown and cooldown_ended
    test_results.append("Cooldown System: %s" % ("PASS" if passed else "FAIL"))

func test_enable_disable():
    dash_module.set_enabled(false)
    var disabled = not dash_module.can_dash()
    dash_module.set_enabled(true)
    await get_tree().create_timer(1.5).timeout  # Wait for cooldown
    var enabled = dash_module.can_dash()
    var passed = disabled and enabled
    test_results.append("Enable/Disable: %s" % ("PASS" if passed else "FAIL"))
```

## Performance Testing

### Check for Memory Leaks
1. Run the game for extended period
2. Execute many dashes (100+)
3. Monitor memory usage in Godot debugger
4. Ensure no memory increases over time

### Frame Rate Impact
1. Monitor FPS counter
2. Execute multiple dashes rapidly
3. Verify no significant FPS drops
4. Check that timers don't accumulate

## Known Limitations

- Module only supports horizontal dashing (by design)
- No built-in animation system integration
- No built-in particle effects
- Requires CharacterBody2D (won't work with RigidBody2D)

## Troubleshooting

### Dash Not Working
- Verify DashModule is child of correct node
- Check that `enabled` is true
- Ensure cooldown has elapsed
- Verify player reference is CharacterBody2D

### Signals Not Firing
- Check signal connections in debugger
- Verify methods are connected correctly
- Look for typos in signal names

### Unexpected Behavior
- Check for conflicting scripts modifying velocity
- Verify delta time is being used correctly
- Check export variables are set to expected values

## Conclusion

The dash module should pass all these tests and demonstrate:
- Clean separation of concerns
- Reliable cooldown management
- Proper invincibility frame handling
- Flexible configuration
- Signal-based event system
- No dependencies on other systems

Report any issues or unexpected behavior for further investigation.
