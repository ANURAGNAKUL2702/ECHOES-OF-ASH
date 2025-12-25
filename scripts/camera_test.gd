extends Node2D
## Test script for the CinematicCamera2D controller
##
## This script demonstrates and tests all camera features:
## - Smooth follow
## - Screen shake
## - Dynamic zoom
## - Dead-zone support
##
## Controls:
## - Movement: WASD/Arrow Keys
## - Shake: Q key
## - Zoom In: E key
## - Zoom Out: R key
## - Reset Zoom: T key
## - Toggle Smooth Follow: F key
## - Toggle Dead Zone: G key

@export var camera: CinematicCamera2D

var test_shake_cooldown: float = 0.0

func _ready() -> void:
	## Initialize test scene
	
	# Find camera if not assigned
	if not camera:
		camera = get_node_or_null("Player/CinematicCamera2D")
	
	if camera:
		# Connect to camera signals for debugging
		camera.shake_started.connect(_on_shake_started)
		camera.shake_ended.connect(_on_shake_ended)
		camera.zoom_changed.connect(_on_zoom_changed)
		
		print("Camera Test Scene Ready!")
		print("Controls:")
		print("  Q - Trigger screen shake")
		print("  E - Zoom in")
		print("  R - Zoom out")
		print("  T - Reset zoom")
		print("  F - Toggle smooth follow")
		print("  G - Toggle dead zone")


func _process(delta: float) -> void:
	## Handle test inputs
	
	# Update cooldown
	if test_shake_cooldown > 0.0:
		test_shake_cooldown -= delta
	
	if not camera:
		return
	
	# Test screen shake (Q key)
	if Input.is_key_label_just_pressed(KEY_Q) and test_shake_cooldown <= 0.0:
		print("Triggering screen shake!")
		camera.shake(15.0, 0.5)
		test_shake_cooldown = 0.6
	
	# Test zoom in (E key - hold for continuous zoom)
	if Input.is_key_label_pressed(KEY_E):
		camera.zoom_in(0.01)
	
	# Test zoom out (R key - hold for continuous zoom)
	if Input.is_key_label_pressed(KEY_R):
		camera.zoom_out(0.01)
	
	# Reset zoom (T key or Insert key)
	if Input.is_key_label_just_pressed(KEY_T) or Input.is_key_label_just_pressed(KEY_INSERT):
		print("Resetting zoom!")
		camera.reset_zoom()
	
	# Toggle smooth follow with F
	if Input.is_key_label_just_pressed(KEY_F):
		camera.smooth_follow = not camera.smooth_follow
		print("Smooth follow: ", camera.smooth_follow)
	
	# Toggle dead zone with G
	if Input.is_key_label_just_pressed(KEY_G):
		camera.enable_dead_zone = not camera.enable_dead_zone
		print("Dead zone: ", camera.enable_dead_zone)


# Signal handlers for debugging
func _on_shake_started(intensity: float, duration: float) -> void:
	print("Screen shake started - Intensity: ", intensity, " Duration: ", duration)


func _on_shake_ended() -> void:
	print("Screen shake ended")


func _on_zoom_changed(new_zoom: Vector2) -> void:
	print("Zoom changed to: ", new_zoom)
