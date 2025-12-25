extends Node2D
## Test script for the ParticleManager
##
## This script demonstrates and tests all features of the ParticleManager:
## - Dash trail particles
## - Impact particles
## - Dust particles
## - Custom effects

# ============================================================================
# CONFIGURATION
# ============================================================================

@export var particle_manager: ParticleManager
@export var player: CharacterBody2D

# ============================================================================
# INTERNAL STATE
# ============================================================================

var _is_dashing: bool = false

# ============================================================================
# BUILT-IN METHODS
# ============================================================================

func _ready() -> void:
	## Initialize the test scene
	
	# Auto-detect if not assigned
	if not particle_manager:
		particle_manager = $ParticleManager
	
	if not player:
		player = $Player
	
	print("=== Particle Manager Test ===")
	print("Controls:")
	print("  Q - Spawn dash trail (hold to continuous)")
	print("  W - Spawn impact at player position")
	print("  E - Spawn dust at player position")
	print("  R - Spawn custom explosion effect")
	print("  1 - Toggle dash trails")
	print("  2 - Toggle impacts")
	print("  3 - Toggle dust")
	print("  C - Clear all particles")
	print("  WASD/Arrows - Move player")
	
	# Add custom explosion effect
	if particle_manager:
		particle_manager.add_custom_effect("explosion", {
			"color": Color(1.0, 0.3, 0.1, 1.0),
			"lifetime": 0.8,
			"scale": 1.5,
			"amount": 25,
			"gravity": true,
			"initial_velocity": Vector2(200, -150),
			"spread": 360.0
		})
		print("Added custom 'explosion' effect")


func _process(_delta: float) -> void:
	## Handle continuous effects
	
	# Continuous dash trail when Q is held
	if Input.is_action_pressed("ui_focus_prev") and player:  # Q key
		if not _is_dashing:
			_is_dashing = true
			if particle_manager:
				particle_manager.start_dash_trail(player)
	else:
		if _is_dashing:
			_is_dashing = false
			if particle_manager:
				particle_manager.stop_dash_trail()


func _input(event: InputEvent) -> void:
	## Handle test controls
	
	if not event is InputEventKey or not event.pressed:
		return
	
	var key_event: InputEventKey = event as InputEventKey
	
	match key_event.keycode:
		KEY_W:
			_spawn_impact()
		KEY_E:
			_spawn_dust()
		KEY_R:
			_spawn_explosion()
		KEY_1:
			_toggle_dash_trails()
		KEY_2:
			_toggle_impacts()
		KEY_3:
			_toggle_dust()
		KEY_C:
			_clear_particles()


# ============================================================================
# TEST METHODS
# ============================================================================

func _spawn_impact() -> void:
	## Spawn impact particles at player position
	
	if not particle_manager or not player:
		return
	
	# Get direction based on player facing or random
	var direction: Vector2 = Vector2.RIGHT
	if player.velocity.x != 0:
		direction = Vector2(sign(player.velocity.x), 0)
	
	particle_manager.spawn_impact(player.global_position, direction)
	print("Spawned impact at ", player.global_position)


func _spawn_dust() -> void:
	## Spawn dust particles at player position
	
	if not particle_manager or not player:
		return
	
	var velocity_x: float = player.velocity.x if player.velocity else 0.0
	particle_manager.spawn_dust(player.global_position, velocity_x)
	print("Spawned dust at ", player.global_position)


func _spawn_explosion() -> void:
	## Spawn custom explosion effect at player position
	
	if not particle_manager or not player:
		return
	
	particle_manager.spawn_custom_effect("explosion", player.global_position)
	print("Spawned explosion at ", player.global_position)


func _toggle_dash_trails() -> void:
	## Toggle dash trail particles
	
	if not particle_manager:
		return
	
	particle_manager.set_effect_enabled("dash_trail", not particle_manager.enable_dash_trails)
	print("Dash trails: ", "ON" if particle_manager.enable_dash_trails else "OFF")


func _toggle_impacts() -> void:
	## Toggle impact particles
	
	if not particle_manager:
		return
	
	particle_manager.set_effect_enabled("impact", not particle_manager.enable_impacts)
	print("Impact particles: ", "ON" if particle_manager.enable_impacts else "OFF")


func _toggle_dust() -> void:
	## Toggle dust particles
	
	if not particle_manager:
		return
	
	particle_manager.set_effect_enabled("dust", not particle_manager.enable_dust)
	print("Dust particles: ", "ON" if particle_manager.enable_dust else "OFF")


func _clear_particles() -> void:
	## Clear all active particles
	
	if not particle_manager:
		return
	
	particle_manager.clear_all_particles()
	print("Cleared all particles")
