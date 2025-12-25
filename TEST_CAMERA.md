# Testing the Cinematic Camera 2D

This document provides comprehensive guidance on testing the `CinematicCamera2D` implementation.

## Test Scene

A dedicated test scene is provided at `scenes/camera_test.tscn` which demonstrates all camera features.

### Running the Test Scene

1. Open the project in Godot 4.2+
2. Navigate to `scenes/camera_test.tscn`
3. Run the scene (F6 or click "Run Current Scene")
4. Use the controls listed in the on-screen instructions

### Test Controls

| Key | Action | Feature Tested |
|-----|--------|----------------|
| A/D or Arrow Keys | Move player | Camera follow |
| Space/W/Up | Jump | Vertical camera follow |
| Q | Trigger shake | Screen shake system |
| E (hold) | Zoom in | Dynamic zoom in |
| R (hold) | Zoom out | Dynamic zoom out |
| T/Insert | Reset zoom | Zoom reset function |
| F | Toggle smooth follow | Smooth vs instant follow |
| G | Toggle dead zone | Dead-zone feature |

## Manual Testing Procedures

### Test 1: Basic Camera Follow

**Objective:** Verify camera follows player smoothly

**Steps:**
1. Run `camera_test.tscn`
2. Move player left and right with A/D keys
3. Observe camera following player

**Expected Results:**
- Camera smoothly follows player movement
- No jittering or stuttering
- Camera movement feels natural and cinematic

**Pass Criteria:**
- ✅ Camera follows player in both directions
- ✅ Movement is smooth with no visible artifacts
- ✅ Damping creates a slight lag (if enabled)

---

### Test 2: Smooth Follow Damping

**Objective:** Verify damping parameters affect follow speed

**Steps:**
1. Run `camera_test.tscn`
2. Move player quickly back and forth
3. Observe camera lag behind player
4. Press F to toggle smooth follow off
5. Move player again

**Expected Results:**
- With smooth follow ON: Camera lags slightly behind rapid movement
- With smooth follow OFF: Camera follows instantly

**Pass Criteria:**
- ✅ Visible difference between smooth and instant follow
- ✅ Smooth follow creates cinematic lag effect
- ✅ Instant follow has no delay

---

### Test 3: Screen Shake

**Objective:** Verify screen shake effect works correctly

**Steps:**
1. Run `camera_test.tscn`
2. Press Q to trigger screen shake
3. Observe camera shaking effect
4. Wait for shake to complete
5. Trigger shake multiple times

**Expected Results:**
- Camera shakes in random directions
- Shake intensity decreases over time
- Shake stops automatically after duration
- Can trigger multiple shakes

**Pass Criteria:**
- ✅ Screen shake is visible and feels impactful
- ✅ Shake oscillates smoothly (not jerky)
- ✅ Shake fades out naturally
- ✅ Console shows "shake started" and "shake ended" messages

---

### Test 4: Dynamic Zoom In

**Objective:** Verify zoom in functionality

**Steps:**
1. Run `camera_test.tscn`
2. Hold E key to zoom in
3. Observe smooth zoom transition
4. Release E key at various zoom levels
5. Note zoom limits

**Expected Results:**
- Camera smoothly zooms in when E is held
- Zoom stops at maximum zoom level (3.0)
- Zoom transition is smooth, not instant

**Pass Criteria:**
- ✅ Zoom increases smoothly
- ✅ Respects max_zoom limit
- ✅ Console shows "Zoom changed to: X" messages
- ✅ Player appears larger on screen

---

### Test 5: Dynamic Zoom Out

**Objective:** Verify zoom out functionality

**Steps:**
1. Run `camera_test.tscn`
2. First zoom in with E
3. Hold R key to zoom out
4. Observe smooth zoom transition
5. Continue zooming to minimum

**Expected Results:**
- Camera smoothly zooms out when R is held
- Zoom stops at minimum zoom level (0.5)
- Zoom transition is smooth

**Pass Criteria:**
- ✅ Zoom decreases smoothly
- ✅ Respects min_zoom limit
- ✅ Player appears smaller on screen
- ✅ More of the scene becomes visible

---

### Test 6: Reset Zoom

**Objective:** Verify zoom reset to base level

**Steps:**
1. Run `camera_test.tscn`
2. Zoom in or out using E/R
3. Press T (or Insert) to reset zoom
4. Observe camera returning to base zoom

**Expected Results:**
- Camera smoothly transitions to base zoom level (1.5)
- Console shows reset message

**Pass Criteria:**
- ✅ Zoom returns to base_zoom value
- ✅ Transition is smooth
- ✅ Works from any zoom level

---

### Test 7: Dead-Zone Feature

**Objective:** Verify dead-zone restricts camera movement

**Steps:**
1. Run `camera_test.tscn`
2. Press G to enable dead zone
3. Move player slightly (within dead zone)
4. Move player more (outside dead zone)
5. Press G again to disable

**Expected Results:**
- With dead zone ON: Small movements don't move camera
- Camera only moves when player approaches screen edge
- With dead zone OFF: Camera follows all movement

**Pass Criteria:**
- ✅ Camera stays still for small movements
- ✅ Camera moves when player exits dead zone
- ✅ Console shows dead zone state changes
- ✅ Dead zone creates stable camera in center of screen

---

### Test 8: Independent Axis Damping

**Objective:** Verify X and Y axes can have different damping (requires config change)

**Steps:**
1. Open `camera_test.tscn`
2. Select CinematicCamera2D node
3. In Inspector, set:
   - `independent_axis_damping = true`
   - `damping_speed_x = 2.0`
   - `damping_speed_y = 8.0`
4. Run the scene
5. Move player horizontally and vertically

**Expected Results:**
- Horizontal follow is slower (damping_speed_x = 2.0)
- Vertical follow is faster (damping_speed_y = 8.0)

**Pass Criteria:**
- ✅ Visible difference in X vs Y follow speed
- ✅ Vertical movement catches up faster than horizontal

---

### Test 9: Multiple Shakes

**Objective:** Verify shake can be triggered repeatedly

**Steps:**
1. Run `camera_test.tscn`
2. Press Q multiple times rapidly
3. Observe shake behavior

**Expected Results:**
- Each press triggers a shake
- Shakes can overlap/stack
- Each shake is visible in console

**Pass Criteria:**
- ✅ Multiple shakes can be triggered
- ✅ No errors or crashes
- ✅ Console shows multiple "shake started" messages

---

### Test 10: Zoom Limits

**Objective:** Verify zoom respects min/max constraints

**Steps:**
1. Run `camera_test.tscn`
2. Hold E for several seconds (zoom in to max)
3. Continue holding E
4. Hold R for several seconds (zoom out to min)
5. Continue holding R

**Expected Results:**
- Zoom in stops at max_zoom (3.0)
- Holding E after max has no effect
- Zoom out stops at min_zoom (0.5)
- Holding R after min has no effect

**Pass Criteria:**
- ✅ Cannot zoom beyond max_zoom
- ✅ Cannot zoom beyond min_zoom
- ✅ No errors when at limits
- ✅ Console shows clamped zoom values

---

## Integration Testing

### Test 11: Add Camera to Existing Scene

**Objective:** Verify camera integrates with existing player scene

**Steps:**
1. Open `scenes/main.tscn`
2. Select the Player/Camera2D node
3. Replace script with `cinematic_camera_2d.gd`
4. Configure parameters in Inspector
5. Run the main scene

**Expected Results:**
- Camera works in main scene
- All features functional
- No interference with existing gameplay

**Pass Criteria:**
- ✅ Camera follows player
- ✅ Player movement still works
- ✅ Platforms and collisions work
- ✅ No console errors

---

### Test 12: Custom Target Following

**Objective:** Verify camera can follow non-player targets

**Steps:**
1. In test scene, add this to camera_test.gd:
```gdscript
func _input(event):
    if event.is_action_pressed("ui_home"):  # Home key
        # Find a platform and follow it
        var platform = get_node("Platforms/Platform1")
        camera.set_follow_target(platform)
```
2. Run scene and press Home key
3. Move player

**Expected Results:**
- Camera stops following player
- Camera stays on the platform

**Pass Criteria:**
- ✅ Camera switches target successfully
- ✅ Player can move independently
- ✅ Camera remains on new target

---

## Automated Testing (Optional)

### Script-Based Tests

Create a test script for automated verification:

```gdscript
extends Node2D

@export var camera: CinematicCamera2D
var test_results = []

func run_all_tests():
    test_shake_api()
    test_zoom_api()
    test_target_switching()
    test_query_methods()
    print_test_results()

func test_shake_api():
    camera.shake(10.0, 0.5)
    assert(camera.is_shaking(), "Camera should be shaking")
    test_results.append("✅ Shake API works")

func test_zoom_api():
    camera.set_zoom(Vector2(2.0, 2.0), true)
    var zoom = camera.get_current_zoom()
    assert(zoom.x == 2.0, "Zoom should be 2.0")
    test_results.append("✅ Zoom API works")

func test_target_switching():
    var old_target = camera.get_follow_target()
    camera.set_follow_target(self)
    var new_target = camera.get_follow_target()
    assert(new_target == self, "Target should change")
    camera.set_follow_target(old_target)
    test_results.append("✅ Target switching works")

func test_query_methods():
    assert(camera.get_current_zoom() != null, "Should return zoom")
    assert(camera.get_shake_intensity() >= 0, "Intensity should be >= 0")
    test_results.append("✅ Query methods work")

func print_test_results():
    print("\n=== Camera Test Results ===")
    for result in test_results:
        print(result)
    print("===========================\n")
```

---

## Performance Testing

### Test 13: Performance Under Load

**Objective:** Verify camera performs well with many objects

**Steps:**
1. Add many sprites/objects to test scene
2. Run scene and observe FPS
3. Trigger shakes while moving
4. Enable/disable dead zone

**Expected Results:**
- Consistent frame rate
- No noticeable lag
- Smooth camera movement

**Pass Criteria:**
- ✅ FPS remains stable (60+ FPS)
- ✅ No dropped frames during shake
- ✅ Dead zone calculations don't impact performance

---

## Bug Reporting

If you find issues during testing, please report:

1. **Issue Description**: What went wrong?
2. **Steps to Reproduce**: How to trigger the bug?
3. **Expected Behavior**: What should happen?
4. **Actual Behavior**: What actually happened?
5. **Configuration**: Camera parameter values used
6. **Godot Version**: Which version of Godot?

---

## Test Checklist

Use this checklist to verify all features:

- [ ] Camera follows player smoothly
- [ ] Smooth follow can be toggled on/off
- [ ] Damping creates natural lag effect
- [ ] Screen shake is visible and impactful
- [ ] Shake fades out naturally
- [ ] Multiple shakes can be triggered
- [ ] Zoom in works and respects max limit
- [ ] Zoom out works and respects min limit
- [ ] Reset zoom returns to base level
- [ ] Zoom transitions are smooth
- [ ] Dead zone prevents small movements from moving camera
- [ ] Dead zone can be toggled on/off
- [ ] Camera can follow different targets
- [ ] Signals emit correctly (check console)
- [ ] No console errors or warnings
- [ ] Performance is acceptable

---

## Additional Test Scenarios

### Scenario 1: Combat Integration
- Trigger shake when player takes damage
- Zoom in during special attacks
- Zoom out when many enemies appear

### Scenario 2: Platforming
- Enable dead zone for stable platforming camera
- Adjust damping for desired feel
- Test with fast horizontal movement

### Scenario 3: Cutscenes
- Switch targets during cutscene
- Use instant zoom for dramatic effect
- Combine zoom and target switching

---

## Troubleshooting Test Issues

**Camera not following:**
- Check follow_target is set correctly
- Verify camera is enabled (Current = true)
- Check parent node is valid Node2D

**Shake not visible:**
- Increase shake_intensity
- Check shake_frequency is reasonable
- Verify shake() is being called

**Zoom issues:**
- Check min/max zoom constraints
- Verify zoom_speed is not too low
- Ensure smooth_zoom is set correctly

**Dead zone not working:**
- Verify enable_dead_zone is true
- Check dead_zone_width/height values
- Test with larger movements

---

## Success Criteria

All tests pass when:
1. ✅ All 13 manual tests pass criteria
2. ✅ No console errors or warnings
3. ✅ Camera feels smooth and cinematic
4. ✅ All features work as documented
5. ✅ Performance is acceptable (60+ FPS)
6. ✅ Integration with existing scenes works
7. ✅ Test checklist is fully completed

---

## Next Steps After Testing

Once all tests pass:
1. Integrate camera into your main game scenes
2. Customize parameters for your game feel
3. Connect signals for game-specific events
4. Implement camera effects in combat/events
5. Document any custom configurations
