extends CharacterBody2D
## A modular enemy AI controller using a finite state machine for Godot 4.
##
## This controller implements a complete enemy AI system with patrol, detection,
## chase, attack, stunned, and death states. It uses RayCast2D for line of sight
## detection and is designed to be reusable across different enemy types.
##
## Features:
## - Finite State Machine with 6 states
## - Line of sight detection using RayCast2D
## - Tunable parameters for detection range and speed
## - No hard-coded player references (uses groups and signals)
## - Clean separation from combat logic
## - Ready for reuse across enemy types
##
## Usage:
## Attach this script to a CharacterBody2D node with:
## - CollisionShape2D for the enemy body
## - RayCast2D for line of sight detection
## - Optional: Navigation and patrol points
##
## The target should be in the "player" group for detection.

class_name EnemyAI

# ============================================================================
# SIGNALS
# ============================================================================

## Emitted when the enemy detects a target
signal target_detected(target: Node2D)

## Emitted when the enemy loses sight of the target
signal target_lost

## Emitted when the enemy is ready to attack
signal attack_ready(target: Node2D)

## Emitted when the enemy is stunned
signal stunned

## Emitted when the enemy dies
signal died

# ============================================================================
# FINITE STATE MACHINE
# ============================================================================

## State enumeration for the enemy AI
## Defines all possible states the enemy can be in
enum State {
	PATROL,   ## Enemy is patrolling an area or idle
	DETECT,   ## Enemy has line of sight to target but is not yet chasing
	CHASE,    ## Enemy is actively pursuing the target
	ATTACK,   ## Enemy is in range and attacking the target
	STUNNED,  ## Enemy is temporarily disabled
	DEATH     ## Enemy has been defeated
}

## Current state of the enemy - exposed for debugging and external access
var current_state: State = State.PATROL

## Previous state of the enemy - useful for state transition logic
var previous_state: State = State.PATROL

# ============================================================================
# DETECTION PARAMETERS
# ============================================================================

## Maximum distance at which the enemy can detect targets (in pixels)
@export var detection_range: float = 400.0

## Angle of detection cone in degrees (360 = full circle)
@export_range(0.0, 360.0) var detection_angle: float = 180.0

## Time in seconds the enemy watches the target before chasing
@export var detection_delay: float = 0.3

## Group name to look for when detecting targets
@export var target_group: String = "player"

# ============================================================================
# MOVEMENT PARAMETERS
# ============================================================================

## Movement speed during patrol (pixels per second)
@export var patrol_speed: float = 100.0

## Movement speed during chase (pixels per second)
@export var chase_speed: float = 200.0

## How close the enemy gets to the target before attacking (pixels)
@export var attack_range: float = 50.0

## Acceleration rate for movement (pixels per second squared)
@export var acceleration: float = 1000.0

## Deceleration rate when stopping (pixels per second squared)
@export var deceleration: float = 1500.0

# ============================================================================
# PATROL PARAMETERS
# ============================================================================

## If true, enemy will move during patrol. If false, enemy stays idle.
@export var patrol_enabled: bool = true

## Distance the enemy moves in one direction during patrol (pixels)
@export var patrol_distance: float = 200.0

## Time the enemy waits at each patrol point (seconds)
@export var patrol_wait_time: float = 2.0

## If true, patrol direction is randomized. If false, alternates left/right.
@export var patrol_random: bool = false

# ============================================================================
# COMBAT PARAMETERS
# ============================================================================

## Time between attacks (seconds)
@export var attack_cooldown: float = 1.5

## Duration of the stunned state (seconds)
@export var stun_duration: float = 2.0

## If true, enemy can be stunned. If false, stun attempts are ignored.
@export var can_be_stunned: bool = true

# ============================================================================
# INTERNAL STATE
# ============================================================================

## Reference to the current target (if any)
var _current_target: Node2D = null

## Timer for detection delay
var _detection_timer: float = 0.0

## Timer for attack cooldown
var _attack_timer: float = 0.0

## Timer for stun duration
var _stun_timer: float = 0.0

## Timer for patrol wait time
var _patrol_timer: float = 0.0

## Starting position for patrol reference
var _patrol_start_position: Vector2

## Current patrol direction (-1 for left, 1 for right)
var _patrol_direction: int = 1

## Flag to prevent state changes during death
var _is_dead: bool = false

## Reference to the RayCast2D node for line of sight
var _raycast: RayCast2D = null

## Cache for project gravity
var _gravity: float = ProjectSettings.get_setting("physics/2d/default_gravity")

# ============================================================================
# BUILT-IN METHODS
# ============================================================================

func _ready() -> void:
	## Initialize the enemy AI controller
	## Set up initial state and find required nodes
	
	# Store starting position for patrol
	_patrol_start_position = global_position
	
	# Find RayCast2D child node
	_raycast = _find_raycast()
	if _raycast:
		_raycast.enabled = true
		_raycast.hit_from_inside = false
	
	# Set initial state
	set_state(State.PATROL)
	
	# Randomize patrol direction if needed
	if patrol_random:
		_patrol_direction = 1 if randf() > 0.5 else -1


func _physics_process(delta: float) -> void:
	## Main physics update loop
	## Handles state updates, movement, and physics
	
	# Skip processing if dead
	if _is_dead:
		return
	
	# Apply gravity if not on floor
	if not is_on_floor():
		velocity.y = min(velocity.y + _gravity * delta, 1000.0)
	
	# Update the state machine
	update_state(delta)
	physics_update_state()
	
	# Apply movement
	move_and_slide()

# ============================================================================
# RAYCAST DETECTION METHODS
# ============================================================================

func _find_raycast() -> RayCast2D:
	## Find the RayCast2D child node
	## Returns null if not found
	
	for child in get_children():
		if child is RayCast2D:
			return child
	return null


func _check_line_of_sight(target: Node2D) -> bool:
	## Check if there is a clear line of sight to the target
	## Uses RayCast2D to detect obstacles
	##
	## Parameters:
	##   target: The node to check line of sight to
	##
	## Returns:
	##   true if line of sight is clear, false otherwise
	
	if not _raycast or not target:
		return false
	
	# Calculate direction to target
	var direction_to_target: Vector2 = (target.global_position - global_position).normalized()
	
	# Check if target is within detection angle
	if detection_angle < 360.0:
		var forward_direction: Vector2 = Vector2.RIGHT if _patrol_direction > 0 else Vector2.LEFT
		var angle_to_target: float = rad_to_deg(forward_direction.angle_to(direction_to_target))
		
		if abs(angle_to_target) > detection_angle / 2.0:
			return false
	
	# Calculate distance to target
	var distance_to_target: float = global_position.distance_to(target.global_position)
	
	# Check if target is within detection range
	if distance_to_target > detection_range:
		return false
	
	# Set raycast to point at target
	_raycast.target_position = to_local(target.global_position)
	_raycast.force_raycast_update()
	
	# Check if raycast hit something
	if _raycast.is_colliding():
		var collider: Object = _raycast.get_collider()
		# Line of sight is clear if we hit the target directly
		return collider == target
	
	# No collision means clear line of sight
	return true


func _find_target_in_range() -> Node2D:
	## Search for a valid target within detection range
	## Looks for nodes in the target_group
	##
	## Returns:
	##   The closest valid target, or null if none found
	
	var closest_target: Node2D = null
	var closest_distance: float = detection_range + 1.0
	
	# Get all nodes in the target group
	var potential_targets: Array[Node] = get_tree().get_nodes_in_group(target_group)
	
	for target in potential_targets:
		if not target is Node2D:
			continue
		
		var distance: float = global_position.distance_to(target.global_position)
		
		# Check if this target is closer and has line of sight
		if distance < closest_distance and _check_line_of_sight(target):
			closest_target = target
			closest_distance = distance
	
	return closest_target

# ============================================================================
# MOVEMENT METHODS
# ============================================================================

func _move_toward_target(target_position: Vector2, speed: float, delta: float) -> void:
	## Move toward a target position at the specified speed
	##
	## Parameters:
	##   target_position: The position to move toward
	##   speed: The desired movement speed
	##   delta: Time since last frame
	
	# Calculate direction to target
	var direction: Vector2 = (target_position - global_position).normalized()
	
	# Update patrol direction for facing
	if abs(direction.x) > 0.1:
		_patrol_direction = 1 if direction.x > 0 else -1
	
	# Accelerate toward target speed
	var target_velocity: float = direction.x * speed
	velocity.x = move_toward(velocity.x, target_velocity, acceleration * delta)


func _apply_deceleration(delta: float) -> void:
	## Decelerate to a stop
	##
	## Parameters:
	##   delta: Time since last frame
	
	velocity.x = move_toward(velocity.x, 0.0, deceleration * delta)

# ============================================================================
# STATE MACHINE METHODS
# ============================================================================

func set_state(new_state: State) -> void:
	## Switch to a new state
	## Handles state transitions and maintains state history
	##
	## Parameters:
	##   new_state: The state to transition to
	
	# Only update if actually changing state
	if new_state == current_state:
		return
	
	# Store the previous state
	previous_state = current_state
	
	# Call exit logic for old state
	_on_state_exit(current_state)
	
	# Transition to new state
	current_state = new_state
	
	# Call entry logic for new state
	_on_state_enter(current_state)


func _on_state_enter(state: State) -> void:
	## Called when entering a new state
	## Initialize state-specific variables
	##
	## Parameters:
	##   state: The state being entered
	
	match state:
		State.PATROL:
			_patrol_timer = patrol_wait_time
			_current_target = null
		
		State.DETECT:
			_detection_timer = 0.0
			target_detected.emit(_current_target)
		
		State.CHASE:
			pass
		
		State.ATTACK:
			_attack_timer = 0.0
		
		State.STUNNED:
			_stun_timer = stun_duration
			velocity = Vector2.ZERO
			stunned.emit()
		
		State.DEATH:
			_is_dead = true
			velocity = Vector2.ZERO
			died.emit()


func _on_state_exit(state: State) -> void:
	## Called when exiting a state
	## Clean up state-specific resources
	##
	## Parameters:
	##   state: The state being exited
	
	match state:
		State.DETECT:
			_detection_timer = 0.0
		
		State.ATTACK:
			_attack_timer = 0.0
		
		_:
			pass


func update_state(delta: float) -> void:
	## Update logic for the current state
	## Runs every frame with state-specific behavior
	##
	## Parameters:
	##   delta: Time since last frame
	
	match current_state:
		State.PATROL:
			_update_patrol_state(delta)
		
		State.DETECT:
			_update_detect_state(delta)
		
		State.CHASE:
			_update_chase_state(delta)
		
		State.ATTACK:
			_update_attack_state(delta)
		
		State.STUNNED:
			_update_stunned_state(delta)
		
		State.DEATH:
			_update_death_state(delta)


func physics_update_state() -> void:
	## Determine which state the enemy should be in
	## Handles state transitions based on conditions
	
	# Death state is permanent
	if current_state == State.DEATH:
		return
	
	# Check if stunned
	if current_state == State.STUNNED:
		# Only exit stunned state when timer expires
		if _stun_timer <= 0.0:
			set_state(State.PATROL)
		return
	
	# Try to find a target
	var target: Node2D = _find_target_in_range()
	
	# If we lost the current target, check if we found it again
	if _current_target and not target:
		_current_target = null
		target_lost.emit()
		set_state(State.PATROL)
		return
	
	# Update current target
	if target:
		_current_target = target
	
	# State transition logic based on target and distance
	if _current_target:
		var distance_to_target: float = global_position.distance_to(_current_target.global_position)
		
		# Check if in attack range
		if distance_to_target <= attack_range:
			if current_state != State.ATTACK:
				set_state(State.ATTACK)
		
		# Check if should chase
		elif current_state == State.DETECT and _detection_timer >= detection_delay:
			set_state(State.CHASE)
		
		# Check if should detect
		elif current_state == State.PATROL:
			set_state(State.DETECT)
	
	else:
		# No target, return to patrol
		if current_state != State.PATROL:
			set_state(State.PATROL)

# ============================================================================
# STATE UPDATE METHODS
# ============================================================================

func _update_patrol_state(delta: float) -> void:
	## Update logic for patrol state
	##
	## Parameters:
	##   delta: Time since last frame
	
	if not patrol_enabled:
		_apply_deceleration(delta)
		return
	
	# Wait at patrol point
	if _patrol_timer > 0.0:
		_patrol_timer -= delta
		_apply_deceleration(delta)
		return
	
	# Calculate patrol target position
	var patrol_offset: float = patrol_distance / 2.0
	var target_x: float = _patrol_start_position.x + (patrol_offset * _patrol_direction)
	var target_position: Vector2 = Vector2(target_x, global_position.y)
	
	# Move toward patrol target
	_move_toward_target(target_position, patrol_speed, delta)
	
	# Check if reached patrol point
	if abs(global_position.x - target_x) < 5.0:
		# Reverse direction
		if patrol_random:
			_patrol_direction = 1 if randf() > 0.5 else -1
		else:
			_patrol_direction *= -1
		
		# Reset wait timer
		_patrol_timer = patrol_wait_time


func _update_detect_state(delta: float) -> void:
	## Update logic for detect state
	##
	## Parameters:
	##   delta: Time since last frame
	
	_detection_timer += delta
	
	# Stay still while detecting
	_apply_deceleration(delta)


func _update_chase_state(delta: float) -> void:
	## Update logic for chase state
	##
	## Parameters:
	##   delta: Time since last frame
	
	if not _current_target:
		return
	
	# Move toward target
	_move_toward_target(_current_target.global_position, chase_speed, delta)


func _update_attack_state(delta: float) -> void:
	## Update logic for attack state
	##
	## Parameters:
	##   delta: Time since last frame
	
	# Update attack cooldown
	_attack_timer += delta
	
	# Stop moving during attack
	_apply_deceleration(delta)
	
	# Emit attack signal when ready
	if _attack_timer >= attack_cooldown and _current_target:
		_attack_timer = 0.0
		attack_ready.emit(_current_target)


func _update_stunned_state(delta: float) -> void:
	## Update logic for stunned state
	##
	## Parameters:
	##   delta: Time since last frame
	
	_stun_timer -= delta
	
	# Stay still while stunned
	_apply_deceleration(delta)


func _update_death_state(_delta: float) -> void:
	## Update logic for death state
	##
	## Parameters:
	##   _delta: Time since last frame (unused)
	
	# Death state is passive - no updates needed
	# Animation and cleanup should be handled externally via the died signal
	pass

# ============================================================================
# PUBLIC API METHODS
# ============================================================================

func stun() -> void:
	## Apply stun effect to the enemy
	## Only works if can_be_stunned is true and enemy is not dead
	
	if can_be_stunned and current_state != State.DEATH:
		set_state(State.STUNNED)


func kill() -> void:
	## Kill the enemy immediately
	## Transitions to death state
	
	set_state(State.DEATH)


func get_state_name() -> String:
	## Returns the current state as a human-readable string
	## Useful for debugging and UI display
	##
	## Returns:
	##   String representation of current state
	
	match current_state:
		State.PATROL:
			return "PATROL"
		State.DETECT:
			return "DETECT"
		State.CHASE:
			return "CHASE"
		State.ATTACK:
			return "ATTACK"
		State.STUNNED:
			return "STUNNED"
		State.DEATH:
			return "DEATH"
		_:
			return "UNKNOWN"


func is_dead() -> bool:
	## Returns true if the enemy is dead
	##
	## Returns:
	##   true if in death state, false otherwise
	
	return _is_dead


func get_target() -> Node2D:
	## Returns the current target being tracked
	##
	## Returns:
	##   Current target node, or null if no target
	
	return _current_target


func set_patrol_bounds(center: Vector2, distance: float) -> void:
	## Set custom patrol boundaries
	##
	## Parameters:
	##   center: Center position for patrol
	##   distance: Total distance to patrol
	
	_patrol_start_position = center
	patrol_distance = distance
