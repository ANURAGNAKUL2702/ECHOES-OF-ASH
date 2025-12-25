# Testing the Atmospheric Systems

This document describes how to test the LightingSystem and ParticleManager implementations.

## Prerequisites

- Godot 4.2 or later installed
- Project opened in Godot editor

## Test Scenes

### 1. Lighting System Test (`lighting_test.tscn`)

**Location**: `res://scenes/lighting_test.tscn`

**What it tests**:
- Player-following light with smooth movement
- Flickering environmental lights
- Fog layers
- Runtime configuration changes
- Dynamic light addition

**How to test**:
1. Open the scene in Godot
2. Run the scene (F5)
3. Use the following controls:

```
Movement:
- WASD or Arrow Keys - Move the player
- Space - Jump

Lighting Controls:
- 1 - Toggle player light on/off
- 2 - Toggle all flickering lights on/off
- 3 - Toggle fog layers on/off
- 4 - Cycle through player light colors
- 5 - Add a random flickering light
- + (or =) - Increase player light brightness
- - - Decrease player light brightness
```

**Expected Results**:
- Player light should smoothly follow the player
- Flickering lights should animate naturally with unique patterns
- Fog should create atmospheric depth effect
- All toggle controls should work immediately
- Light color should cycle through predefined colors
- Adding lights should spawn at random positions
- Brightness adjustments should be visible

**Visual Indicators**:
- Scene should be dark with CanvasModulate
- Player light creates a visible glow around player
- Flickering lights pulse smoothly
- Fog creates layered atmospheric effect

---

### 2. Particle Manager Test (`particle_test.tscn`)

**Location**: `res://scenes/particle_test.tscn`

**What it tests**:
- Dash trail particles (continuous emission)
- Impact particles (directional burst)
- Dust particles (landing effects)
- Custom particle effects
- Effect toggling
- Particle cleanup

**How to test**:
1. Open the scene in Godot
2. Run the scene (F5)
3. Use the following controls:

```
Movement:
- WASD or Arrow Keys - Move the player
- Space - Jump

Particle Controls:
- Q (hold) - Continuous dash trail emission
- W - Spawn impact at player position
- E - Spawn dust at player position
- R - Spawn custom explosion effect
- 1 - Toggle dash trails on/off
- 2 - Toggle impacts on/off
- 3 - Toggle dust on/off
- C - Clear all active particles
```

**Expected Results**:
- Holding Q should create a trail behind the player
- W should spawn directional impact particles
- E should spawn dust that drifts and falls
- R should spawn a large explosion effect
- Toggles should immediately enable/disable effects
- C should clear all particles from screen

**Visual Indicators**:
- Dash trails: Cyan/blue particles following player
- Impacts: Yellow/gold burst in direction
- Dust: Brown particles rising and falling
- Explosion: Red/orange particles spreading outward

---

### 3. Main Scene Integration Test (`main.tscn`)

**Location**: `res://scenes/main.tscn`

**What it tests**:
- Automatic atmospheric integration
- Player light following during gameplay
- Automatic landing dust detection
- All systems working together
- Performance in real gameplay

**How to test**:
1. Open the scene in Godot
2. Run the scene (F5)
3. Play naturally:

```
Gameplay:
- Move and jump around platforms
- Land from different heights
- Observe lighting following player
- Watch for automatic dust on landing
```

**Expected Results**:
- Player light should follow smoothly during movement
- Fog should create atmospheric depth
- Landing dust should spawn automatically on hard landings
- All systems should work without manual triggering
- Performance should be smooth (60 FPS)

**Visual Indicators**:
- Dark scene with player light illumination
- Automatic dust clouds on landing
- Atmospheric fog layers
- Smooth camera and light follow

---

## Manual Testing Checklist

### Lighting System
- [ ] Player light follows player smoothly
- [ ] Flickering lights animate with natural variation
- [ ] Fog layers create depth effect
- [ ] Can toggle player light on/off
- [ ] Can toggle flickering lights on/off
- [ ] Can toggle fog on/off
- [ ] Can change player light color
- [ ] Can add lights at runtime
- [ ] Can adjust light brightness
- [ ] Lights have proper z-ordering
- [ ] No performance issues with multiple lights

### Particle Manager
- [ ] Dash trails follow player when active
- [ ] Impact particles spawn in correct direction
- [ ] Dust particles rise and fall naturally
- [ ] Custom effects can be created and spawned
- [ ] Can toggle each effect type
- [ ] Particles clean up automatically
- [ ] Maximum particle limit is respected
- [ ] Particles have proper z-ordering
- [ ] No performance issues with many particles
- [ ] Particle colors and lifetimes are correct

### Atmospheric Integration
- [ ] Auto-detects all system components
- [ ] Player light setup works automatically
- [ ] Landing dust spawns on hard landings
- [ ] No dust on soft landings
- [ ] Systems work together without conflicts
- [ ] No errors in console output
- [ ] Performance is acceptable

---

## Performance Testing

### Expected Performance Targets
- **Frame Rate**: 60 FPS on modern hardware
- **Max Active Particles**: 30-50 systems
- **Max Flickering Lights**: 15-20 on screen
- **Memory Usage**: Minimal increase (< 50MB)

### Performance Test Procedure
1. Open main.tscn
2. Run with profiler enabled (Debug > Profiler)
3. Jump and land repeatedly (spawn particles)
4. Move through lit areas
5. Monitor:
   - Frame time (should stay < 16.67ms for 60 FPS)
   - Active particle systems count
   - Memory usage

### Performance Issues to Watch For
- Frame drops when spawning many particles
- Stuttering when adding lights
- Memory leaks (increasing memory over time)
- Lag with many active effects

**If performance issues occur**:
- Reduce `max_active_particles` in ParticleManager
- Lower particle counts per effect
- Reduce `fog_layer_count` in LightingSystem
- Decrease number of flickering lights

---

## Common Issues and Solutions

### Lights Not Visible
**Problem**: Lights don't show up or are too dim

**Solutions**:
1. Ensure CanvasModulate is set to dark color
2. Increase light energy values
3. Check light z-index is appropriate
4. Verify `enable_player_light` is true

### Particles Not Spawning
**Problem**: Particle effects don't appear

**Solutions**:
1. Check effect type is enabled in inspector
2. Verify ParticleManager is in scene
3. Check particle z-index is high enough
4. Ensure particle colors have sufficient alpha
5. Verify method calls are reaching the manager

### Performance Issues
**Problem**: Game runs slowly with effects active

**Solutions**:
1. Lower `max_active_particles` setting
2. Reduce particle count per effect
3. Decrease fog layer count
4. Limit number of flickering lights
5. Increase cleanup frequency

### Integration Not Working
**Problem**: Atmospheric integration doesn't connect systems

**Solutions**:
1. Check all nodes are named correctly
2. Verify scripts have class_name defined
3. Check nodes are in scene hierarchy
4. Review console for error messages
5. Manually assign references in inspector

---

## Automated Testing (Future)

While the current implementation relies on manual testing, future improvements could include:

### Unit Tests
- Light position tracking accuracy
- Particle spawn and cleanup
- Configuration validation
- Signal emission verification

### Integration Tests
- Multi-system interaction
- Performance benchmarks
- Memory leak detection
- Edge case handling

### Visual Tests
- Screenshot comparison
- Animation consistency
- Color accuracy
- Effect timing

---

## Test Results Documentation

When testing, document results in this format:

```
Test Date: YYYY-MM-DD
Godot Version: 4.x.x
Hardware: [CPU/GPU/RAM]

Lighting System:
✓ Player light follows correctly
✓ Flickering lights animate
✓ Fog displays properly
✗ Light color cycling has slight delay [MINOR]

Particle Manager:
✓ All particle types spawn correctly
✓ Performance is acceptable
✓ Cleanup works as expected

Integration:
✓ Auto-detection successful
✓ Landing dust works
✓ No console errors

Performance:
- Average FPS: 60
- Particle count peak: 45
- Frame time: 15.2ms average
- Memory usage: +35MB

Notes:
[Any additional observations or issues]
```

---

## Reporting Issues

If you find bugs or issues:

1. Note the exact steps to reproduce
2. Include Godot version and OS
3. Capture console output if errors present
4. Take screenshots if visual issue
5. Note performance impact if applicable
6. Check if issue occurs in test scenes

---

## Success Criteria

The implementation is successful if:

1. **Functionality**: All features work as documented
2. **Performance**: Maintains 60 FPS with typical usage
3. **Stability**: No crashes or errors during testing
4. **Usability**: Easy to configure and integrate
5. **Quality**: Code is clean, documented, and maintainable
6. **Extensibility**: New effects can be added easily

---

## Next Steps After Testing

1. Fix any bugs discovered
2. Optimize performance if needed
3. Add any requested features
4. Update documentation based on findings
5. Create additional examples if helpful
