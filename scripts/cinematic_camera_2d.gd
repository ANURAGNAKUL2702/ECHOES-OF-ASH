extends Camera2D
## A cinematic 2D camera controller for Godot 4.
##
## This controller implements smooth camera follow, screen shake, dynamic zoom,
## and dead-zone support for creating polished camera behaviors in 2D games.
##
## Features:
## - Smooth camera follow with configurable damping
## - Screen shake triggered by impacts or custom events
## - Dynamic zoom for combat or gameplay emphasis
## - Optional dead-zone to restrict camera movement
## - Player-independent design for maximum reusability
##
## Usage:
## Attach this script to a Camera2D node. Set the target node reference
## or the camera will automatically follow its parent.

class_name CinematicCamera2D

# ============================================================================
# CAMERA FOLLOW PARAMETERS
# ============================================================================

## The node the camera should follow. If null, follows parent node.
@export var follow_target: Node2D = null

## Enable smooth camera follow with damping
@export var smooth_follow: bool = true

## Horizontal damping speed (higher = faster follow)
@export_range(0.1, 20.0) var damping_speed_x: float = 5.0

## Vertical damping speed (higher = faster follow)
@export_range(0.1, 20.0) var damping_speed_y: float = 5.0

## Enable separate damping speeds for X and Y axes
@export var independent_axis_damping: bool = false

# ============================================================================
# DEAD-ZONE PARAMETERS
# ============================================================================

## Enable dead-zone support (camera only moves when target leaves dead zone)
@export var enable_dead_zone: bool = false

## Width of the dead-zone rectangle (in pixels)
@export_range(0.0, 500.0) var dead_zone_width: float = 100.0

## Height of the dead-zone rectangle (in pixels)
@export_range(0.0, 500.0) var dead_zone_height: float = 80.0

# ============================================================================
# ZOOM PARAMETERS
# ============================================================================

## Base zoom level for the camera
@export var base_zoom: Vector2 = Vector2(1.5, 1.5)

## Smooth zoom transitions
@export var smooth_zoom: bool = true

## Zoom transition speed (higher = faster zoom changes)
@export_range(0.1, 10.0) var zoom_speed: float = 3.0

## Minimum allowed zoom (higher = more zoomed in)
@export var min_zoom: Vector2 = Vector2(0.5, 0.5)

## Maximum allowed zoom (lower = more zoomed out)
@export var max_zoom: Vector2 = Vector2(3.0, 3.0)

# ============================================================================
# SCREEN SHAKE PARAMETERS
# ============================================================================

## Default shake intensity (pixels)
@export_range(0.0, 50.0) var default_shake_intensity: float = 10.0

## Default shake duration (seconds)
@export_range(0.0, 2.0) var default_shake_duration: float = 0.3

## Shake decay rate (how quickly shake diminishes)
@export_range(0.0, 10.0) var shake_decay: float = 5.0

## Shake frequency (higher = faster oscillation)
@export_range(0.0, 50.0) var shake_frequency: float = 15.0

# ============================================================================
# INTERNAL STATE
# ============================================================================

## Current target zoom level
var _target_zoom: Vector2 = Vector2.ONE

## Current shake intensity (decreases over time)
var _current_shake_intensity: float = 0.0

## Remaining shake duration
var _shake_time_remaining: float = 0.0

## Random offset for shake effect
var _shake_offset: Vector2 = Vector2.ZERO

## Camera's base position (before shake offset)
var _base_camera_position: Vector2 = Vector2.ZERO

## Cache of the target node for performance
var _cached_target: Node2D = null

# ============================================================================
# SIGNALS
# ============================================================================

## Emitted when screen shake starts
signal shake_started(intensity: float, duration: float)

## Emitted when screen shake ends
signal shake_ended()

## Emitted when zoom changes
signal zoom_changed(new_zoom: Vector2)

# ============================================================================
# BUILT-IN METHODS
# ============================================================================

func _ready() -> void:
	## Initialize the camera controller
	
	# Set initial zoom
	_target_zoom = base_zoom
	zoom = base_zoom
	
	# Determine follow target
	_update_target_cache()
	
	# Initialize base camera position
	if _cached_target:
		_base_camera_position = _cached_target.global_position
		global_position = _base_camera_position


func _process(delta: float) -> void:
	## Main update loop for camera effects
	
	# Update screen shake
	_update_shake(delta)
	
	# Update zoom
	_update_zoom(delta)
	
	# Update camera follow
	_update_follow(delta)


# ============================================================================
# CAMERA FOLLOW METHODS
# ============================================================================

func _update_target_cache() -> void:
	## Update the cached target reference
	
	if follow_target:
		_cached_target = follow_target
	else:
		# Use parent as target if no explicit target is set
		var parent = get_parent()
		if parent is Node2D:
			_cached_target = parent


func _update_follow(delta: float) -> void:
	## Update camera position to follow target
	
	# Ensure we have a valid target
	if not _cached_target:
		_update_target_cache()
		return
	
	if not _cached_target or not is_instance_valid(_cached_target):
		return
	
	# Get target position
	var target_pos = _cached_target.global_position
	
	# Apply dead-zone if enabled
	if enable_dead_zone:
		target_pos = _apply_dead_zone(target_pos)
	
	# Update base camera position with damping
	if smooth_follow:
		if independent_axis_damping:
			# Separate damping for X and Y axes
			_base_camera_position.x = lerp(_base_camera_position.x, target_pos.x, damping_speed_x * delta)
			_base_camera_position.y = lerp(_base_camera_position.y, target_pos.y, damping_speed_y * delta)
		else:
			# Unified damping using X damping speed
			_base_camera_position = _base_camera_position.lerp(target_pos, damping_speed_x * delta)
	else:
		# No damping - instant follow
		_base_camera_position = target_pos
	
	# Apply camera position with shake offset
	global_position = _base_camera_position + _shake_offset


func _apply_dead_zone(target_pos: Vector2) -> Vector2:
	## Apply dead-zone logic to target position
	## Returns the position the camera should move toward
	
	var camera_pos = _base_camera_position
	var result = camera_pos
	
	# Calculate dead-zone bounds
	var half_width = dead_zone_width * 0.5
	var half_height = dead_zone_height * 0.5
	
	# Check X axis
	if target_pos.x < camera_pos.x - half_width:
		result.x = target_pos.x + half_width
	elif target_pos.x > camera_pos.x + half_width:
		result.x = target_pos.x - half_width
	
	# Check Y axis
	if target_pos.y < camera_pos.y - half_height:
		result.y = target_pos.y + half_height
	elif target_pos.y > camera_pos.y + half_height:
		result.y = target_pos.y - half_height
	
	return result

# ============================================================================
# SCREEN SHAKE METHODS
# ============================================================================

func _update_shake(delta: float) -> void:
	## Update screen shake effect
	
	if _shake_time_remaining <= 0.0:
		# No active shake
		_shake_offset = Vector2.ZERO
		_current_shake_intensity = 0.0
		return
	
	# Decrease shake time
	_shake_time_remaining -= delta
	
	# Decay shake intensity over time
	_current_shake_intensity = max(0.0, _current_shake_intensity - shake_decay * delta)
	
	# Generate shake offset using sine wave for smooth oscillation
	var shake_amount = _current_shake_intensity
	var time_seconds = Time.get_ticks_msec() * 0.001
	_shake_offset.x = sin(time_seconds * shake_frequency) * shake_amount
	_shake_offset.y = cos(time_seconds * shake_frequency * 0.7) * shake_amount
	
	# Check if shake has ended
	if _shake_time_remaining <= 0.0:
		_shake_offset = Vector2.ZERO
		shake_ended.emit()


func shake(intensity: float = -1.0, duration: float = -1.0) -> void:
	## Trigger a screen shake effect
	##
	## Parameters:
	##   intensity: Shake strength in pixels (uses default_shake_intensity if -1)
	##   duration: How long the shake lasts in seconds (uses default_shake_duration if -1)
	##
	## Example:
	##   camera.shake(15.0, 0.5)  # Shake with intensity 15 for 0.5 seconds
	##   camera.shake()  # Use default values
	
	var shake_intensity = intensity if intensity >= 0.0 else default_shake_intensity
	var shake_duration = duration if duration >= 0.0 else default_shake_duration
	
	# Set shake parameters
	_current_shake_intensity = shake_intensity
	_shake_time_remaining = shake_duration
	
	# Emit signal
	shake_started.emit(shake_intensity, shake_duration)

# ============================================================================
# ZOOM METHODS
# ============================================================================

func _update_zoom(delta: float) -> void:
	## Update camera zoom with smooth transitions
	
	if smooth_zoom:
		# Smoothly interpolate to target zoom
		zoom = zoom.lerp(_target_zoom, zoom_speed * delta)
	else:
		# Instant zoom
		zoom = _target_zoom


func set_zoom(new_zoom: Vector2, instant: bool = false) -> void:
	## Set the camera zoom level
	##
	## Parameters:
	##   new_zoom: The target zoom level (higher = more zoomed in)
	##   instant: If true, zoom changes immediately without smoothing
	##
	## Example:
	##   camera.set_zoom(Vector2(2.0, 2.0))  # Zoom in 2x
	##   camera.set_zoom(Vector2(1.0, 1.0), true)  # Instant zoom to 1x
	
	# Clamp zoom to min/max values
	new_zoom.x = clamp(new_zoom.x, min_zoom.x, max_zoom.x)
	new_zoom.y = clamp(new_zoom.y, min_zoom.y, max_zoom.y)
	
	_target_zoom = new_zoom
	
	if instant:
		zoom = new_zoom
	
	# Emit signal
	zoom_changed.emit(new_zoom)


func reset_zoom(instant: bool = false) -> void:
	## Reset camera zoom to base zoom level
	##
	## Parameters:
	##   instant: If true, zoom changes immediately without smoothing
	
	set_zoom(base_zoom, instant)


func zoom_in(amount: float = 0.2) -> void:
	## Zoom in by a relative amount
	##
	## Parameters:
	##   amount: How much to increase zoom (default: 0.2)
	##
	## Example:
	##   camera.zoom_in(0.5)  # Zoom in by 0.5
	
	var new_zoom = _target_zoom + Vector2(amount, amount)
	set_zoom(new_zoom)


func zoom_out(amount: float = 0.2) -> void:
	## Zoom out by a relative amount
	##
	## Parameters:
	##   amount: How much to decrease zoom (default: 0.2)
	##
	## Example:
	##   camera.zoom_out(0.5)  # Zoom out by 0.5
	
	var new_zoom = _target_zoom - Vector2(amount, amount)
	set_zoom(new_zoom)

# ============================================================================
# PUBLIC API METHODS
# ============================================================================

func is_shaking() -> bool:
	## Returns true if screen shake is currently active
	return _shake_time_remaining > 0.0


func get_shake_intensity() -> float:
	## Returns the current shake intensity
	return _current_shake_intensity


func get_current_zoom() -> Vector2:
	## Returns the current zoom level
	return zoom


func get_target_zoom() -> Vector2:
	## Returns the target zoom level
	return _target_zoom


func set_follow_target(target: Node2D) -> void:
	## Set a new follow target for the camera
	##
	## Parameters:
	##   target: The Node2D to follow (or null to follow parent)
	
	follow_target = target
	_update_target_cache()


func get_follow_target() -> Node2D:
	## Returns the current follow target
	return _cached_target


func enable_smooth_follow(enable: bool) -> void:
	## Enable or disable smooth camera follow
	##
	## Parameters:
	##   enable: True to enable smooth follow, false for instant follow
	
	smooth_follow = enable


func set_damping_speed(speed: float) -> void:
	## Set the damping speed for camera follow
	##
	## Parameters:
	##   speed: Damping speed (higher = faster follow)
	
	damping_speed_x = speed
	damping_speed_y = speed


func set_dead_zone(enabled: bool, width: float = 100.0, height: float = 80.0) -> void:
	## Configure the camera dead-zone
	##
	## Parameters:
	##   enabled: Whether to enable dead-zone
	##   width: Width of the dead-zone in pixels
	##   height: Height of the dead-zone in pixels
	
	enable_dead_zone = enabled
	dead_zone_width = width
	dead_zone_height = height
