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

## Cache for the project's default gravity
var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# ============================================================================
# BUILT-IN METHODS
# ============================================================================

func _ready() -> void:
	## Initialize the player controller
	# Ensure the gravity is properly set
	_gravity = ProjectSettings.get_setting("physics/2d/default_gravity")


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
	# Apply reduced gravity when holding jump (for variable jump height)
	elif velocity.y < 0 and Input.is_action_pressed("jump") and not _jump_consumed:
		current_gravity *= jump_height_control
	
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
