extends CharacterBody2D
## A production-quality 2D player movement controller for Godot 4.
##
## This controller implements smooth horizontal movement with acceleration/deceleration,
## gravity-based jumping, coyote time, and jump buffering for responsive gameplay.
## 
## Features:
## - Smooth acceleration and deceleration for horizontal movement
## - Gravity-based jumping with variable jump height
## - Coyote time: allows jumping shortly after walking off edges
## - Jump buffering: registers jump inputs shortly before landing
## 
## Usage:
## Attach this script to a CharacterBody2D node with a CollisionShape2D child.
## The controller responds to "move_left", "move_right", and "jump" input actions.

class_name Player2D

# ============================================================================
# FINITE STATE MACHINE
# ============================================================================

## State enumeration for the player
## Defines all possible states the player can be in
enum State {
	IDLE,  ## Player is on the ground and not moving
	RUN,   ## Player is on the ground and moving horizontally
	JUMP,  ## Player is in the air and moving upward
	FALL   ## Player is in the air and moving downward
}

## Current state of the player - exposed for debugging and external access
var current_state: State = State.IDLE

## Previous state of the player - useful for state transition logic
var previous_state: State = State.IDLE

# ============================================================================
# MOVEMENT PARAMETERS
# ============================================================================

## Maximum horizontal movement speed in pixels per second
@export var max_speed: float = 300.0

## Horizontal acceleration when moving (pixels per second squared)
@export var acceleration: float = 2000.0

## Horizontal deceleration when stopping (pixels per second squared)
@export var friction: float = 2500.0

## Air resistance multiplier when in the air (0.0 to 1.0)
@export_range(0.0, 1.0) var air_resistance: float = 0.5

# ============================================================================
# JUMP PARAMETERS
# ============================================================================

## Initial upward velocity when jumping (pixels per second)
@export var jump_velocity: float = -450.0

## Gravity multiplier (uses project gravity setting from Physics 2D)
@export var gravity_multiplier: float = 1.0

## Additional gravity when falling (makes falling feel snappier)
@export var fall_gravity_multiplier: float = 1.5

## Maximum falling speed (terminal velocity)
@export var max_fall_speed: float = 800.0

# ============================================================================
# ADVANCED JUMP PARAMETERS
# ============================================================================

## Coyote time duration in seconds
## Allows the player to jump for a short time after walking off a platform
@export var coyote_time: float = 0.15

## Jump buffer duration in seconds
## Registers jump input slightly before landing
@export var jump_buffer_time: float = 0.1

## Variable jump height: multiplier for reduced gravity when holding jump
@export_range(0.0, 1.0) var jump_height_control: float = 0.5

# ============================================================================
# INTERNAL STATE
# ============================================================================

## Tracks time since the player was last on the ground (for coyote time)
var _time_since_grounded: float = 0.0

## Tracks time since jump was pressed (for jump buffering)
var _time_since_jump_pressed: float = 0.0

## Flag to prevent multiple jumps from a single button press
var _jump_consumed: bool = false

## Flag to track if player is in an active jump (for variable jump height)
var _is_jumping: bool = false

## Cache for the project's default gravity
var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# ============================================================================
# BUILT-IN METHODS
# ============================================================================

func _ready() -> void:
	## Initialize the player controller
	## Set initial state to IDLE
	set_state(State.IDLE)


func _physics_process(delta: float) -> void:
	## Main physics update loop
	## Handles all movement, jumping, and physics calculations
	
	# Update timers
	_update_timers(delta)
	
	# Handle vertical movement (gravity and jumping)
	_apply_gravity(delta)
	_handle_jump_input()
	_apply_jump()
	
	# Handle horizontal movement
	_handle_horizontal_movement(delta)
	
	# Apply the movement
	move_and_slide()
	
	# Update grounded state after movement
	_update_grounded_state()
	
	# Update the finite state machine
	physics_update_state()
	update_state(delta)

# ============================================================================
# MOVEMENT METHODS
# ============================================================================

func _handle_horizontal_movement(delta: float) -> void:
	## Process horizontal movement with acceleration and deceleration
	
	# Get input direction: -1 for left, 1 for right, 0 for no input
	var input_direction: float = Input.get_axis("move_left", "move_right")
	
	if input_direction != 0.0:
		# Player is pressing a movement key
		_accelerate_horizontal(input_direction, delta)
	else:
		# Player is not pressing any movement keys
		_apply_friction(delta)


func _accelerate_horizontal(direction: float, delta: float) -> void:
	## Accelerate the player in the given direction
	
	# Determine acceleration rate based on whether player is grounded
	var accel_rate: float = acceleration
	if not is_on_floor():
		# Reduce acceleration in the air
		accel_rate *= air_resistance
	
	# Apply acceleration
	velocity.x = move_toward(velocity.x, max_speed * direction, accel_rate * delta)


func _apply_friction(delta: float) -> void:
	## Decelerate the player when no input is given
	
	# Determine friction rate based on whether player is grounded
	var friction_rate: float = friction
	if not is_on_floor():
		# Reduce friction in the air
		friction_rate *= air_resistance
	
	# Apply friction
	velocity.x = move_toward(velocity.x, 0.0, friction_rate * delta)

# ============================================================================
# JUMP AND GRAVITY METHODS
# ============================================================================

func _apply_gravity(delta: float) -> void:
	## Apply gravity to the player
	
	# Don't apply gravity if on the floor
	if is_on_floor():
		return
	
	# Calculate gravity based on player state
	var current_gravity: float = _gravity * gravity_multiplier
	
	# Apply stronger gravity when falling
	if velocity.y > 0:
		current_gravity *= fall_gravity_multiplier
		_is_jumping = false  # No longer jumping if falling
	# Apply reduced gravity when holding jump (for variable jump height)
	elif velocity.y < 0 and Input.is_action_pressed("jump") and _is_jumping:
		current_gravity *= jump_height_control
	else:
		# If not holding jump or moving up, end the jump state
		if velocity.y < 0 and not Input.is_action_pressed("jump"):
			_is_jumping = false
	
	# Apply gravity and clamp to max fall speed
	velocity.y = min(velocity.y + current_gravity * delta, max_fall_speed)


func _handle_jump_input() -> void:
	## Check for jump input and update the jump buffer
	
	if Input.is_action_just_pressed("jump"):
		# Reset the jump buffer timer when jump is pressed
		_time_since_jump_pressed = 0.0


func _apply_jump() -> void:
	## Apply jump if conditions are met (coyote time or jump buffer)
	
	# Check if we can jump based on coyote time
	var can_coyote_jump: bool = _time_since_grounded <= coyote_time
	
	# Check if we have a buffered jump
	var has_buffered_jump: bool = _time_since_jump_pressed <= jump_buffer_time
	
	# Only jump if we're allowed to and haven't already consumed this jump
	if has_buffered_jump and can_coyote_jump and not _jump_consumed:
		velocity.y = jump_velocity
		_jump_consumed = true
		_is_jumping = true  # Start jump state for variable height
		# Reset timers to prevent further jumps
		_time_since_grounded = coyote_time + 1.0
		_time_since_jump_pressed = jump_buffer_time + 1.0

# ============================================================================
# STATE MANAGEMENT METHODS
# ============================================================================

func _update_timers(delta: float) -> void:
	## Update internal timers for coyote time and jump buffering
	
	_time_since_grounded += delta
	_time_since_jump_pressed += delta


func _update_grounded_state() -> void:
	## Update the grounded state after movement
	
	if is_on_floor():
		# Reset timers when on the ground
		_time_since_grounded = 0.0
		_jump_consumed = false
		_is_jumping = false

# ============================================================================
# FINITE STATE MACHINE METHODS
# ============================================================================

func set_state(new_state: State) -> void:
	## Switch to a new state
	## This method handles state transitions and maintains state history
	## 
	## Parameters:
	##   new_state: The state to transition to
	##
	## Note: This method stores the previous state before transitioning,
	## which can be useful for conditional logic based on state changes
	
	# Only update if actually changing state
	if new_state == current_state:
		return
	
	# Store the previous state for reference
	previous_state = current_state
	
	# Transition to the new state
	current_state = new_state
	
	# Optional: Add state entry logic here if needed in the future
	# For example: _on_state_entered(current_state)


func update_state(dt: float) -> void:
	## General update logic for states
	## This method can be extended to handle state-specific update logic
	## that runs every frame regardless of physics calculations
	##
	## Parameters:
	##   dt: Delta time in seconds
	##
	## Note: Currently acts as a placeholder for future state-specific
	## logic such as animation updates, timers, or state-dependent behavior
	
	# State-specific update logic can be added here
	# For now, this serves as an extension point for future enhancements
	match current_state:
		State.IDLE:
			pass  # Future: Handle idle-specific updates
		State.RUN:
			pass  # Future: Handle run-specific updates
		State.JUMP:
			pass  # Future: Handle jump-specific updates
		State.FALL:
			pass  # Future: Handle fall-specific updates


func physics_update_state() -> void:
	## State-specific actions during physics processing
	## This method determines which state the player should be in based on
	## their current movement and position, then transitions accordingly
	##
	## State Determination Logic:
	##   - JUMP: Player is moving upward (negative Y velocity)
	##   - FALL: Player is moving downward (positive Y velocity)
	##   - RUN: Player is on the ground and moving horizontally
	##   - IDLE: Player is on the ground and not moving
	##
	## Note: States are checked in priority order to ensure correct behavior
	
	var new_state: State = current_state
	
	# Determine the appropriate state based on player movement
	if not is_on_floor():
		# Player is in the air
		if velocity.y < 0:
			# Moving upward - jumping
			new_state = State.JUMP
		else:
			# Moving downward - falling
			new_state = State.FALL
	else:
		# Player is on the ground
		if abs(velocity.x) > 0.1:
			# Moving horizontally - running
			new_state = State.RUN
		else:
			# Not moving - idle
			new_state = State.IDLE
	
	# Transition to the determined state
	set_state(new_state)

# ============================================================================
# PUBLIC API METHODS
# ============================================================================

func get_movement_direction() -> float:
	## Returns the current movement direction (-1 left, 0 none, 1 right)
	return sign(velocity.x)


func is_moving() -> bool:
	## Returns true if the player is moving horizontally
	return abs(velocity.x) > 0.1


func is_jumping() -> bool:
	## Returns true if the player is moving upward
	return velocity.y < 0 and not is_on_floor()


func is_falling() -> bool:
	## Returns true if the player is falling
	return velocity.y > 0 and not is_on_floor()


func get_state_name() -> String:
	## Returns the current state as a human-readable string
	## Useful for debugging and UI display
	match current_state:
		State.IDLE:
			return "IDLE"
		State.RUN:
			return "RUN"
		State.JUMP:
			return "JUMP"
		State.FALL:
			return "FALL"
		_:
			return "UNKNOWN"
