# Testing the Finite State Machine

This document describes how to test the new finite state machine implementation.

## Manual Testing in Godot Editor

1. Open the project in Godot 4
2. Open the scene `scenes/main.tscn`
3. Run the project (F5)

## Testing State Transitions

### Expected Behavior:

1. **IDLE State**
   - When: Player is on the ground and not moving
   - Test: Start the game without pressing any keys
   - Expected: `current_state` should be `State.IDLE`

2. **RUN State**
   - When: Player is on the ground and moving horizontally
   - Test: Press A/D or Left/Right arrow keys while on the ground
   - Expected: `current_state` should transition to `State.RUN`

3. **JUMP State**
   - When: Player is in the air and moving upward (velocity.y < 0)
   - Test: Press Space/W/Up arrow while on the ground
   - Expected: `current_state` should transition to `State.JUMP`

4. **FALL State**
   - When: Player is in the air and moving downward (velocity.y > 0)
   - Test: Walk off a platform or wait at the peak of a jump
   - Expected: `current_state` should transition to `State.FALL`

## Debugging FSM State

You can add a debug label to visualize the current state:

1. Add a Label node to the Player scene
2. In the Player script, add this to `_physics_process`:
   ```gdscript
   $Label.text = "State: " + get_state_name()
   ```

## API Testing

The FSM exposes these public methods:

- `set_state(state: State)` - Manually set the player state
- `update_state(dt: float)` - Called every frame for state-specific logic
- `physics_update_state()` - Called during physics processing to update state
- `get_state_name() -> String` - Get the current state as a string

## State Transition Flow

```
IDLE ←→ RUN    (when horizontal movement starts/stops on ground)
  ↓      ↓
JUMP → FALL    (when jumping or falling)
  ↓      ↓
IDLE or RUN    (when landing, depending on horizontal movement)
```

## Variables Available for Inspection

- `current_state: State` - The current state of the player
- `previous_state: State` - The previous state (useful for transition logic)

These can be accessed from other scripts or inspected in the debugger.
