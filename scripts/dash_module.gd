extends Node
## A standalone dash module for 2D action games in Godot 4.
##
## This module provides a configurable dash mechanic with cooldown and invincibility frames.
## It is designed to be completely independent and does not read player input directly.
## Instead, it exposes a `dash(player)` method that should be called by the player controller
## or input handler.
##
## Features:
## - Short burst of horizontal movement with configurable speed and duration
## - Cooldown timer to prevent consecutive dashes
## - Temporary invincibility frames (i-frames) during dash
## - Enable/disable toggle for progression-based unlocking
## - No dependencies on other game systems (combat, camera, etc.)
##
## Usage:
## 1. Add this node as a child to your player or game manager
## 2. Call `dash(player)` method when dash input is detected
## 3. Use `is_dashing()` and `is_invincible()` to query dash state
## 4. Use `can_dash()` to check if dash is available
## 5. Use `set_enabled(bool)` to unlock/lock the dash ability

class_name DashModule

# ============================================================================
# SIGNALS
# ============================================================================

## Emitted when a dash starts
signal dash_started()

## Emitted when a dash ends
signal dash_ended()

## Emitted when dash comes off cooldown
signal dash_ready()

# ============================================================================
# DASH PARAMETERS
# ============================================================================

## Speed multiplier during dash (pixels per second)
## This multiplies with the player's base speed or can be used as absolute speed
@export var dash_speed: float = 600.0

## Duration of the dash in seconds
@export var dash_duration: float = 0.2

## Cooldown time between dashes in seconds
@export var dash_cooldown: float = 1.0

## Duration of invincibility frames during dash in seconds
## Set to 0 to disable i-frames
@export var iframe_duration: float = 0.15

## Whether the dash ability is enabled (for progression-based unlocking)
@export var enabled: bool = true

## Direction lock during dash (if true, player can't change direction mid-dash)
@export var lock_direction: bool = true

## Control influence during dash when direction is not locked (0.0 to 1.0)
## Higher values allow more player control, lower values maintain dash momentum
@export_range(0.0, 1.0) var dash_control: float = 0.8

# ============================================================================
# INTERNAL STATE
# ============================================================================

## Current dash timer (counts down during dash)
var _dash_timer: float = 0.0

## Current cooldown timer (counts down after dash)
var _cooldown_timer: float = 0.0

## Current invincibility timer (counts down during dash)
var _iframe_timer: float = 0.0

## Direction of the current dash (-1 for left, 1 for right, 0 for none)
var _dash_direction: float = 0.0

## Reference to the player currently dashing (null if not dashing)
var _dashing_player: CharacterBody2D = null

## Flag to track if cooldown finished notification was sent
var _cooldown_ready_notified: bool = true

# ============================================================================
# BUILT-IN METHODS
# ============================================================================

func _ready() -> void:
	## Initialize the dash module
	set_process(true)


func _process(delta: float) -> void:
	## Update dash timers and state
	_update_timers(delta)
	_update_dash_movement(delta)


# ============================================================================
# PUBLIC API METHODS
# ============================================================================

func dash(player: CharacterBody2D, direction: float = 0.0) -> bool:
	## Execute a dash for the given player
	## 
	## Parameters:
	##   player: The CharacterBody2D node to apply the dash to
	##   direction: The dash direction (-1 left, 1 right, 0 auto-detect from horizontal velocity)
	##
	## Returns:
	##   true if dash was executed, false if dash is on cooldown or disabled
	##
	## Note: This method should be called by the player controller or input handler,
	## NOT directly from input events. This maintains separation of concerns.
	
	# Check if dash is available
	if not can_dash():
		return false
	
	# Determine dash direction
	var dash_dir: float = direction
	if dash_dir == 0.0:
		# Auto-detect from player's current movement
		if player.velocity.x != 0:
			dash_dir = sign(player.velocity.x)
		else:
			# Default to right if no movement
			dash_dir = 1.0
	
	# Start the dash
	_start_dash(player, dash_dir)
	return true


func can_dash() -> bool:
	## Check if dash is currently available
	## 
	## Returns:
	##   true if dash can be executed (not on cooldown and enabled)
	return enabled and _cooldown_timer <= 0.0 and _dash_timer <= 0.0


func is_dashing() -> bool:
	## Check if a dash is currently in progress
	##
	## Returns:
	##   true if currently dashing
	return _dash_timer > 0.0


func is_invincible() -> bool:
	## Check if invincibility frames are currently active
	##
	## Returns:
	##   true if i-frames are active
	return _iframe_timer > 0.0


func get_cooldown_progress() -> float:
	## Get the current cooldown progress as a value from 0.0 to 1.0
	##
	## Returns:
	##   0.0 when dash is ready, 1.0 when cooldown just started
	if dash_cooldown <= 0.0:
		return 0.0
	return clamp(_cooldown_timer / dash_cooldown, 0.0, 1.0)


func get_dash_direction() -> float:
	## Get the current dash direction
	##
	## Returns:
	##   -1 for left, 1 for right, 0 if not dashing
	if is_dashing():
		return _dash_direction
	return 0.0


func set_enabled(value: bool) -> void:
	## Enable or disable the dash ability
	##
	## Parameters:
	##   value: true to enable dash, false to disable
	##
	## Use this for progression-based unlocking or temporary disabling
	enabled = value


func cancel_dash() -> void:
	## Immediately cancel the current dash
	##
	## This stops the dash movement but cooldown still applies
	if is_dashing():
		_end_dash()

# ============================================================================
# INTERNAL METHODS
# ============================================================================

func _start_dash(player: CharacterBody2D, direction: float) -> void:
	## Start a dash in the given direction
	##
	## Parameters:
	##   player: The CharacterBody2D to dash
	##   direction: The dash direction (-1 or 1)
	
	# Set dash state
	_dash_timer = dash_duration
	_dash_direction = direction
	_dashing_player = player
	_iframe_timer = iframe_duration
	_cooldown_ready_notified = false
	
	# Apply initial dash velocity
	if player:
		player.velocity.x = dash_speed * _dash_direction
	
	# Emit signal
	dash_started.emit()


func _end_dash() -> void:
	## End the current dash and start cooldown
	
	# Clear dash state
	_dash_timer = 0.0
	_dash_direction = 0.0
	_dashing_player = null
	
	# Start cooldown
	_cooldown_timer = dash_cooldown
	
	# Emit signal
	dash_ended.emit()


func _update_timers(delta: float) -> void:
	## Update all internal timers
	##
	## Parameters:
	##   delta: Delta time in seconds
	
	# Update dash timer
	if _dash_timer > 0.0:
		_dash_timer -= delta
		if _dash_timer <= 0.0:
			_end_dash()
	
	# Update cooldown timer
	if _cooldown_timer > 0.0:
		_cooldown_timer -= delta
		if _cooldown_timer <= 0.0:
			# Cooldown finished
			if not _cooldown_ready_notified:
				_cooldown_ready_notified = true
				dash_ready.emit()
	
	# Update invincibility timer
	if _iframe_timer > 0.0:
		_iframe_timer -= delta


func _update_dash_movement(delta: float) -> void:
	## Maintain dash velocity during dash duration
	##
	## Parameters:
	##   delta: Delta time in seconds
	
	if not is_dashing() or not _dashing_player:
		return
	
	# Maintain dash velocity
	if lock_direction:
		# Lock the horizontal velocity to dash speed
		_dashing_player.velocity.x = dash_speed * _dash_direction
	else:
		# Allow some control but prioritize dash
		var dash_velocity: float = dash_speed * _dash_direction
		_dashing_player.velocity.x = lerp(_dashing_player.velocity.x, dash_velocity, dash_control)

# ============================================================================
# HELPER METHODS
# ============================================================================

func get_time_until_ready() -> float:
	## Get the time remaining until dash is ready again
	##
	## Returns:
	##   Time in seconds until dash is available (0.0 if ready)
	return max(0.0, _cooldown_timer)
