extends Node2D
## Example integration of CinematicCamera2D into an existing game
##
## This script demonstrates how to integrate the cinematic camera
## with gameplay events, showing common use cases like:
## - Screen shake on player damage
## - Zoom effects during special actions
## - Dynamic camera behavior based on game state
##
## Usage:
## 1. Add CinematicCamera2D to your player node
## 2. Reference it in your game controller or player script
## 3. Call camera methods in response to game events

# Reference to the cinematic camera
@export var camera: CinematicCamera2D

# Example: Player reference
@export var player: CharacterBody2D

func _ready() -> void:
	## Setup camera connections
	
	# Find camera if not assigned
	if not camera and player:
		camera = player.get_node_or_null("CinematicCamera2D")
	
	if camera:
		# Connect to camera signals for feedback
		camera.shake_started.connect(_on_camera_shake_started)
		camera.zoom_changed.connect(_on_camera_zoom_changed)
		
		print("Camera integration ready!")
	else:
		print("Warning: CinematicCamera2D not found!")


# ============================================================================
# EXAMPLE: Combat Integration
# ============================================================================

func _on_player_damaged(damage: float) -> void:
	## Trigger screen shake when player takes damage
	## Shake intensity scales with damage amount
	
	if not camera:
		return
	
	# Scale shake intensity with damage (minimum 5, maximum 30)
	var shake_intensity = clamp(damage * 2.0, 5.0, 30.0)
	var shake_duration = 0.3
	
	camera.shake(shake_intensity, shake_duration)


func _on_enemy_hit() -> void:
	## Small shake when player hits an enemy
	
	if not camera:
		return
	
	camera.shake(8.0, 0.2)


func _on_explosion_near_player(distance: float) -> void:
	## Shake based on proximity to explosion
	
	if not camera:
		return
	
	# Closer explosions shake more
	var intensity = clamp(50.0 / distance, 5.0, 25.0)
	camera.shake(intensity, 0.5)


# ============================================================================
# EXAMPLE: Zoom Integration
# ============================================================================

func _on_enter_combat_area() -> void:
	## Zoom in when entering combat
	
	if not camera:
		return
	
	camera.set_zoom(Vector2(2.0, 2.0))


func _on_exit_combat_area() -> void:
	## Zoom back to normal after combat
	
	if not camera:
		return
	
	camera.reset_zoom()


func _on_special_attack_charged() -> void:
	## Zoom in during special attack charge
	
	if not camera:
		return
	
	camera.zoom_in(0.3)


func _on_special_attack_released() -> void:
	## Zoom out when attack is released
	
	if not camera:
		return
	
	camera.zoom_out(0.3)


# ============================================================================
# EXAMPLE: Boss Fight Integration
# ============================================================================

func start_boss_introduction(boss: Node2D) -> void:
	## Cinematic boss introduction sequence
	
	if not camera:
		return
	
	# Focus camera on boss
	camera.set_follow_target(boss)
	camera.set_zoom(Vector2(1.8, 1.8))
	
	# Dramatic shake
	camera.shake(20.0, 1.0)
	
	# Wait for introduction
	await get_tree().create_timer(3.0).timeout
	
	# Return to player
	camera.set_follow_target(player)
	camera.reset_zoom()


func _on_boss_phase_change() -> void:
	## Shake and zoom effect during boss phase transition
	
	if not camera:
		return
	
	# Intense shake
	camera.shake(25.0, 0.8)
	
	# Brief zoom out to show full arena
	camera.set_zoom(Vector2(1.2, 1.2))
	await get_tree().create_timer(1.5).timeout
	camera.reset_zoom()


# ============================================================================
# EXAMPLE: Environmental Effects
# ============================================================================

func _on_earthquake() -> void:
	## Long-duration shake for earthquake effect
	
	if not camera:
		return
	
	camera.shake(15.0, 2.0)


func _on_building_collapse() -> void:
	## Heavy shake for building collapse
	
	if not camera:
		return
	
	camera.shake(30.0, 1.5)


# ============================================================================
# EXAMPLE: Cutscene Integration
# ============================================================================

func play_cutscene(waypoints: Array[Node2D]) -> void:
	## Move camera through waypoints for cutscene
	
	if not camera:
		return
	
	# Disable smooth follow for precise control
	camera.enable_smooth_follow(false)
	
	# Move through each waypoint
	for waypoint in waypoints:
		camera.set_follow_target(waypoint)
		await get_tree().create_timer(2.0).timeout
	
	# Re-enable smooth follow and return to player
	camera.enable_smooth_follow(true)
	camera.set_follow_target(player)


# ============================================================================
# EXAMPLE: Dead-Zone for Platforming
# ============================================================================

func enable_platforming_camera() -> void:
	## Configure camera for platforming sections
	
	if not camera:
		return
	
	# Enable dead-zone for less camera movement
	camera.set_dead_zone(true, 150.0, 100.0)
	
	# Slower damping for platforming feel
	camera.set_damping_speed(3.0)


func enable_exploration_camera() -> void:
	## Configure camera for exploration sections
	
	if not camera:
		return
	
	# Disable dead-zone for free camera movement
	camera.set_dead_zone(false)
	
	# Faster damping for responsive camera
	camera.set_damping_speed(6.0)


# ============================================================================
# EXAMPLE: Power-up Visual Feedback
# ============================================================================

func _on_power_up_collected() -> void:
	## Visual feedback when collecting power-up
	
	if not camera:
		return
	
	# Quick zoom pulse
	camera.zoom_in(0.4)
	await get_tree().create_timer(0.1).timeout
	camera.zoom_out(0.4)
	
	# Small shake
	camera.shake(5.0, 0.2)


# ============================================================================
# EXAMPLE: Death/Respawn
# ============================================================================

func _on_player_death() -> void:
	## Camera effect on player death
	
	if not camera:
		return
	
	# Zoom in on player
	camera.set_zoom(Vector2(2.5, 2.5), true)
	
	# Shake
	camera.shake(20.0, 0.5)


func _on_player_respawn() -> void:
	## Reset camera on respawn
	
	if not camera:
		return
	
	# Reset zoom
	camera.reset_zoom()
	
	# Re-focus on player
	camera.set_follow_target(player)


# ============================================================================
# Signal Handlers (for feedback/audio)
# ============================================================================

func _on_camera_shake_started(intensity: float, duration: float) -> void:
	## Called when shake starts - can trigger screen flash, sound effects, etc.
	print("Camera shake: intensity=", intensity, " duration=", duration)
	
	# Example: Play rumble sound effect
	# audio_player.play_rumble_sound(intensity)


func _on_camera_zoom_changed(new_zoom: Vector2) -> void:
	## Called when zoom changes - can update UI, trigger effects, etc.
	print("Camera zoom changed to: ", new_zoom)
	
	# Example: Update UI scale based on zoom
	# ui_controller.adjust_scale_for_zoom(new_zoom)


# ============================================================================
# Utility Methods
# ============================================================================

func is_camera_ready() -> bool:
	## Check if camera is available
	return camera != null and is_instance_valid(camera)


func get_camera_zoom() -> Vector2:
	## Get current camera zoom level
	if is_camera_ready():
		return camera.get_current_zoom()
	return Vector2.ONE


func is_camera_shaking() -> bool:
	## Check if camera is currently shaking
	if is_camera_ready():
		return camera.is_shaking()
	return false
