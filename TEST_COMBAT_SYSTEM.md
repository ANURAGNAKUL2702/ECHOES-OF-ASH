# Testing the Melee Combat System

This document provides comprehensive testing procedures for the Melee Combat Controller.

## Automated Tests

### Running the Test Script

1. Open Godot 4 Editor
2. Open `scripts/test_combat_system.gd`
3. Run the script (Ctrl+Shift+X or use "Run" menu)
4. Check console output for test results

### Expected Test Output

```
=== MELEE COMBAT SYSTEM TEST ===

--- Testing MeleeCombatController ---
✓ Initial state correct
✓ Attack execution works
✓ Attack direction correct
✓ MeleeCombatController tests passed

--- Testing Hitbox ---
✓ Hitbox initial state correct
✓ Hitbox enable/disable works
✓ Hitbox attack direction works
✓ Hitbox tests passed

--- Testing Hurtbox ---
✓ Hurtbox initial state correct
✓ Hurtbox damage reception works
✓ Hurtbox i-frame tracking works
✓ Hurtbox tests passed

--- Testing Combo System ---
✓ First combo hit works
✓ Second combo hit works
✓ Third combo hit works
✓ Combo loops correctly
✓ Combo reset works
✓ Combo system tests passed

=== ALL TESTS COMPLETED ===
```

## Manual Testing

### Test 1: Basic Combat Setup

**Objective**: Verify the combat system integrates correctly with a player character.

**Steps**:
1. Create a new scene with a CharacterBody2D
2. Add a MeleeCombatController node as a child
3. Add a Hitbox node as a child of MeleeCombatController
4. Add a CollisionShape2D to the Hitbox (use RectangleShape2D, size: 20x20)
5. Add a Hurtbox node as a child of the CharacterBody2D
6. Add a CollisionShape2D to the Hurtbox (use RectangleShape2D, size: 30x30)
7. Run the scene

**Expected Result**:
- Scene runs without errors
- Console shows no warnings
- All nodes are properly initialized

### Test 2: Attack Input

**Objective**: Verify attack input triggers correctly.

**Steps**:
1. Use the scene from Test 1
2. Add a script to the CharacterBody2D:
   ```gdscript
   extends CharacterBody2D
   
   func _physics_process(_delta: float) -> void:
       if Input.is_action_just_pressed("attack"):
           print("Attack pressed!")
           $MeleeCombatController.attack(1.0)
   ```
3. Run the scene
4. Press J or Z key

**Expected Result**:
- "Attack pressed!" appears in console
- No errors occur

### Test 3: Directional Attacks

**Objective**: Verify attacks can be executed in different directions.

**Steps**:
1. Modify the script from Test 2:
   ```gdscript
   func _physics_process(_delta: float) -> void:
       if Input.is_action_just_pressed("attack"):
           var dir = 1.0 if Input.is_action_pressed("move_right") else -1.0
           $MeleeCombatController.attack(dir)
           print("Attacking in direction: ", dir)
   ```
2. Run the scene
3. Hold D and press J
4. Hold A and press J

**Expected Result**:
- Console shows "Attacking in direction: 1.0" when pressing D+J
- Console shows "Attacking in direction: -1.0" when pressing A+J

### Test 4: Combo System

**Objective**: Verify the 3-hit combo chain works correctly.

**Steps**:
1. Use the scene from Test 1
2. Add signal connections:
   ```gdscript
   func _ready() -> void:
       $MeleeCombatController.attack_started.connect(func(num):
           print("Attack ", num, " started! Combo: ", $MeleeCombatController.get_combo_count())
       )
       $MeleeCombatController.combo_reset.connect(func():
           print("Combo reset!")
       )
   ```
3. Run the scene
4. Press J three times quickly
5. Wait 2 seconds
6. Press J once

**Expected Result**:
- First J: "Attack 1 started! Combo: 1"
- Second J: "Attack 2 started! Combo: 2"
- Third J: "Attack 3 started! Combo: 3"
- After wait: "Combo reset!"
- Fourth J: "Attack 1 started! Combo: 1"

### Test 5: Hitbox Detection

**Objective**: Verify hitbox detects hurtbox collisions.

**Steps**:
1. Create a scene with two CharacterBody2D nodes (Player and Enemy)
2. Player setup:
   - Add MeleeCombatController + Hitbox (with CollisionShape2D)
   - Add Hurtbox (with CollisionShape2D)
3. Enemy setup:
   - Add Hurtbox (with CollisionShape2D)
   - Position enemy near player (within attack range)
4. Add to player script:
   ```gdscript
   func _ready() -> void:
       $MeleeCombatController/Hitbox.hit_landed.connect(func(hurtbox):
           print("Hit landed on: ", hurtbox.get_parent().name)
       )
   
   func _physics_process(_delta: float) -> void:
       if Input.is_action_just_pressed("attack"):
           $MeleeCombatController.attack(1.0)
   ```
5. Add to enemy Hurtbox:
   ```gdscript
   func _ready() -> void:
       damage_taken.connect(func(dmg, kf, kd):
           print("Enemy took ", dmg, " damage with knockback ", kf)
       )
   ```
6. Run the scene
7. Press J to attack

**Expected Result**:
- Console shows "Hit landed on: Enemy"
- Console shows "Enemy took 10.0 damage with knockback 200.0"

### Test 6: Invincibility Frames

**Objective**: Verify i-frames prevent multiple hits.

**Steps**:
1. Use the scene from Test 5
2. Modify enemy Hurtbox to log all damage attempts:
   ```gdscript
   func _ready() -> void:
       damage_taken.connect(func(dmg, _kf, _kd):
           print("Damage taken: ", dmg)
       )
       iframe_started.connect(func():
           print("I-frames started")
       )
       iframe_ended.connect(func():
           print("I-frames ended")
       )
   ```
3. Run the scene
4. Press J rapidly multiple times

**Expected Result**:
- First hit: "Damage taken: 10.0" and "I-frames started"
- Subsequent rapid hits: No additional "Damage taken" messages
- After ~0.5s: "I-frames ended"
- Next hit: "Damage taken: X" again

### Test 7: Knockback Scaling

**Objective**: Verify knockback is scaled by weight.

**Steps**:
1. Create scene with 3 enemies with different weights:
   - Light enemy: weight = 0.5
   - Normal enemy: weight = 1.0
   - Heavy enemy: weight = 2.0
2. Add velocity tracking to each:
   ```gdscript
   func _ready() -> void:
       $Hurtbox.damage_taken.connect(func(_d, kf, _kd):
           print(name, " knockback: ", kf, " velocity: ", velocity)
       )
   ```
3. Attack each enemy

**Expected Result**:
- Light enemy: Higher velocity after hit
- Normal enemy: Medium velocity
- Heavy enemy: Lower velocity
- Knockback values: Light (400), Normal (200), Heavy (100)

### Test 8: Combat State Queries

**Objective**: Verify state query methods work correctly.

**Steps**:
1. Use basic combat scene
2. Add to player script:
   ```gdscript
   func _process(_delta: float) -> void:
       print("Attacking: ", $Combat.is_attacking())
       print("Can attack: ", $Combat.can_attack())
       print("Combo: ", $Combat.get_combo_count())
       print("Direction: ", $Combat.get_attack_direction())
   ```
3. Run and observe console

**Expected Result**:
- Values change appropriately during attacks
- is_attacking() true during attack, false otherwise
- can_attack() inverse of is_attacking()
- get_combo_count() shows current combo (0-3)

### Test 9: Attack Cancellation

**Objective**: Verify attacks can be cancelled.

**Steps**:
1. Use basic combat scene
2. Add to script:
   ```gdscript
   func _physics_process(_delta: float) -> void:
       if Input.is_action_just_pressed("attack"):
           $Combat.attack(1.0)
       
       if Input.is_action_just_pressed("jump"):
           $Combat.cancel_attack()
           print("Attack cancelled!")
   ```
3. Press J to start attack
4. Immediately press Space

**Expected Result**:
- Attack starts
- "Attack cancelled!" appears in console
- Attack stops immediately

### Test 10: Enabling/Disabling Combat

**Objective**: Verify combat can be toggled on/off.

**Steps**:
1. Use basic combat scene
2. Add to script:
   ```gdscript
   func _ready() -> void:
       # Disable combat after 2 seconds
       await get_tree().create_timer(2.0).timeout
       $Combat.set_enabled(false)
       print("Combat disabled")
       
       # Re-enable after 2 more seconds
       await get_tree().create_timer(2.0).timeout
       $Combat.set_enabled(true)
       print("Combat enabled")
   
   func _physics_process(_delta: float) -> void:
       if Input.is_action_just_pressed("attack"):
           var result = $Combat.attack(1.0)
           print("Attack result: ", result)
   ```
3. Run and try attacking at different times

**Expected Result**:
- Attacks work initially
- After 2s: "Combat disabled", attacks fail (return false)
- After 4s: "Combat enabled", attacks work again

## Integration Testing

### Test 11: With Movement System

**Objective**: Verify combat integrates with Player2D movement.

**Steps**:
1. Open `scenes/player.tscn`
2. Add MeleeCombatController + Hitbox to player
3. Add Hurtbox to player
4. Modify player script to handle attack input
5. Run main scene
6. Try moving and attacking simultaneously

**Expected Result**:
- Player can move while attacking (or with reduced speed if configured)
- Attacks work in both directions based on movement
- No conflicts between systems

### Test 12: With Dash Module

**Objective**: Verify combat and dash work together.

**Steps**:
1. Setup player with both DashModule and MeleeCombatController
2. Try attacking during dash
3. Try dashing during attack

**Expected Result**:
- Both systems work independently
- No crashes or conflicts
- Behavior is predictable

## Performance Testing

### Test 13: Multiple Enemies

**Objective**: Verify system handles multiple entities efficiently.

**Steps**:
1. Create scene with 20 enemies
2. Each has a Hurtbox
3. Attack sweeping through multiple enemies
4. Monitor FPS

**Expected Result**:
- No significant FPS drop
- All collisions detected correctly
- No errors or warnings

## Edge Case Testing

### Test 14: Rapid Input

**Objective**: Verify system handles spam input gracefully.

**Steps**:
1. Setup basic combat scene
2. Rapidly press J key (10+ times per second)
3. Observe behavior

**Expected Result**:
- No crashes
- Combo system works correctly
- Attack queuing works as expected

### Test 15: Invalid Configurations

**Objective**: Verify system handles edge case parameters.

**Steps**:
1. Set attack_1_duration to 0
2. Set combo_window to 0
3. Set iframe_duration to 0
4. Set weight to 0
5. Test each configuration

**Expected Result**:
- System doesn't crash
- Behavior degrades gracefully
- No divide-by-zero errors

## Checklist

Before considering the combat system complete, verify:

- [ ] All automated tests pass
- [ ] All manual tests pass
- [ ] No console errors or warnings
- [ ] Combat works with existing player controller
- [ ] Hitbox/Hurtbox collision detection works
- [ ] Combo system chains correctly
- [ ] I-frames prevent multi-hit
- [ ] Knockback scales with weight
- [ ] Signals emit at correct times
- [ ] State queries return correct values
- [ ] Can enable/disable combat
- [ ] Can cancel attacks
- [ ] Direction detection works
- [ ] Performance is acceptable
- [ ] Edge cases handled gracefully

## Troubleshooting

### If tests fail:

1. **Check Godot version**: Ensure using Godot 4.2+
2. **Verify scene structure**: Nodes must be children as documented
3. **Check collision shapes**: Must have CollisionShape2D children
4. **Review collision layers**: Layers 3 and 4 should be free
5. **Check input actions**: "attack" action must be defined
6. **Verify scripts attached**: All scripts properly attached to nodes
7. **Console output**: Look for specific error messages

### Common Issues:

- **No collision**: Check collision shapes overlap
- **No signals**: Verify signal connections
- **Combo not working**: Check timing parameters
- **I-frames not working**: Verify iframe_duration > 0
- **No knockback**: Check parent is CharacterBody2D

## Reporting Issues

If you find issues, report with:
1. Godot version
2. Test that failed
3. Expected vs actual behavior
4. Console output
5. Scene structure
6. Script modifications (if any)

## Success Criteria

The melee combat system is working correctly when:
1. All automated tests pass without errors
2. Manual tests produce expected results
3. System integrates cleanly with existing code
4. Performance is acceptable (60 FPS with 20+ enemies)
5. No console warnings or errors
6. Documentation matches implementation
