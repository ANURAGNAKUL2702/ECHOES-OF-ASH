extends Node2D
## A modular particle effect manager for 2D action games in Godot 4.
##
## This system provides a centralized, extensible particle management system
## for various game effects including dash trails, impacts, and landing dust.
##
## Features:
## - Dash trail particles that follow the player during dash
## - Impact particles for combat hits
## - Dust particles for landing effects
## - Easily extensible architecture for adding new effects
## - Automatic particle cleanup and pooling
## - Performance-optimized defaults
##
## Usage:
## 1. Add this node to your scene
## 2. Call spawn_dash_trail(position) during dash
## 3. Call spawn_impact(position, direction) on hit
## 4. Call spawn_dust(position) on landing
## 5. Add new effect types by extending the system

class_name ParticleManager

# ============================================================================
# SIGNALS
# ============================================================================

## Emitted when a particle effect is spawned
signal particle_spawned(effect_type: String, position: Vector2)

## Emitted when the particle system is initialized
signal particle_system_initialized()

# ============================================================================
# DASH TRAIL PARAMETERS
# ============================================================================

## Enable dash trail particles
@export var enable_dash_trails: bool = true

## Color of dash trail particles
@export var dash_trail_color: Color = Color(0.5, 0.8, 1.0, 0.8)  # Cyan/blue

## Lifetime of dash trail particles in seconds
@export var dash_trail_lifetime: float = 0.3

## Scale of dash trail particles
@export var dash_trail_scale: float = 0.5

## Number of particles per trail emission
@export_range(1, 20) var dash_trail_amount: int = 3

## Time between trail emissions during dash
@export var dash_trail_interval: float = 0.05

# ============================================================================
# IMPACT PARAMETERS
# ============================================================================

## Enable impact particles
@export var enable_impacts: bool = true

## Color of impact particles
@export var impact_color: Color = Color(1.0, 0.9, 0.3, 1.0)  # Yellow/gold

## Lifetime of impact particles in seconds
@export var impact_lifetime: float = 0.4

## Scale of impact particles
@export var impact_scale: float = 1.0

## Number of particles per impact
@export_range(5, 50) var impact_particle_count: int = 15

## Spread angle of impact particles in degrees
@export_range(0, 360) var impact_spread_angle: float = 120.0

## Impact particle initial velocity
@export var impact_velocity: float = 150.0

# ============================================================================
# DUST PARAMETERS
# ============================================================================

## Enable dust particles
@export var enable_dust: bool = true

## Color of dust particles
@export var dust_color: Color = Color(0.7, 0.6, 0.5, 0.6)  # Brownish dust

## Lifetime of dust particles in seconds
@export var dust_lifetime: float = 0.5

## Scale of dust particles
@export var dust_scale: float = 0.8

## Number of particles per dust emission
@export_range(3, 30) var dust_particle_count: int = 8

## Spread of dust particles horizontally
@export var dust_spread: float = 50.0

## Dust particle initial upward velocity
@export var dust_velocity: float = 80.0

# ============================================================================
# GENERAL PARAMETERS
# ============================================================================

## Z-index for particle rendering
@export var particle_z_index: int = 100

## Enable gravity for particles (dust and impacts)
@export var use_gravity: bool = true

## Gravity strength for particles
@export var particle_gravity: float = 300.0

## Maximum number of active particle systems (for performance)
@export var max_active_particles: int = 50

# ============================================================================
# INTERNAL STATE
# ============================================================================

## Container for all particle effects
var _particle_container: Node2D = null

## Active particle systems
var _active_particles: Array[GPUParticles2D] = []

## Timer for dash trail emission
var _dash_trail_timer: float = 0.0

## Currently tracked dash target
var _dash_target: Node2D = null

## Flag indicating if currently dashing
var _is_dashing: bool = false

# ============================================================================
# PARTICLE EFFECT DEFINITIONS
# ============================================================================

## Predefined particle effect configurations
var _effect_configs: Dictionary = {}

# ============================================================================
# BUILT-IN METHODS
# ============================================================================

func _ready() -> void:
	## Initialize the particle manager
	_setup_container()
	_initialize_effect_configs()
	particle_system_initialized.emit()


func _process(delta: float) -> void:
	## Update particle effects
	_update_dash_trails(delta)
	_cleanup_finished_particles()


# ============================================================================
# SETUP METHODS
# ============================================================================

func _setup_container() -> void:
	## Create container node for organization
	_particle_container = Node2D.new()
	_particle_container.name = "Particles"
	_particle_container.z_index = particle_z_index
	add_child(_particle_container)


func _initialize_effect_configs() -> void:
	## Initialize predefined particle effect configurations
	
	# Dash trail configuration
	_effect_configs["dash_trail"] = {
		"color": dash_trail_color,
		"lifetime": dash_trail_lifetime,
		"scale": dash_trail_scale,
		"amount": dash_trail_amount,
		"gravity": false,
		"initial_velocity": Vector2.ZERO,
		"spread": 20.0
	}
	
	# Impact configuration
	_effect_configs["impact"] = {
		"color": impact_color,
		"lifetime": impact_lifetime,
		"scale": impact_scale,
		"amount": impact_particle_count,
		"gravity": use_gravity,
		"initial_velocity": Vector2(impact_velocity, 0),
		"spread": impact_spread_angle
	}
	
	# Dust configuration
	_effect_configs["dust"] = {
		"color": dust_color,
		"lifetime": dust_lifetime,
		"scale": dust_scale,
		"amount": dust_particle_count,
		"gravity": use_gravity,
		"initial_velocity": Vector2(0, -dust_velocity),
		"spread": dust_spread
	}


# ============================================================================
# PUBLIC API METHODS - DASH TRAILS
# ============================================================================

func start_dash_trail(target: Node2D) -> void:
	## Start emitting dash trail particles for a target
	##
	## Parameters:
	##   target: The Node2D to follow and emit trails from
	##
	## Call this when a dash starts
	
	if not enable_dash_trails:
		return
	
	_dash_target = target
	_is_dashing = true
	_dash_trail_timer = 0.0


func stop_dash_trail() -> void:
	## Stop emitting dash trail particles
	##
	## Call this when a dash ends
	
	_is_dashing = false
	_dash_target = null


func spawn_dash_trail(pos: Vector2) -> void:
	## Spawn a single dash trail particle at position
	##
	## Parameters:
	##   pos: World position to spawn the trail
	##
	## Note: Usually called automatically by start_dash_trail()
	## but can be called manually for custom trail effects
	
	if not enable_dash_trails:
		return
	
	_spawn_particle_effect("dash_trail", pos, Vector2.ZERO)


# ============================================================================
# PUBLIC API METHODS - IMPACTS
# ============================================================================

func spawn_impact(pos: Vector2, direction: Vector2 = Vector2.RIGHT) -> void:
	## Spawn impact particles at position
	##
	## Parameters:
	##   pos: World position to spawn the impact
	##   direction: Direction of impact (for particle spread)
	##
	## Use this for combat hits, collisions, or any impact effect
	
	if not enable_impacts:
		return
	
	_spawn_particle_effect("impact", pos, direction.normalized())
	particle_spawned.emit("impact", pos)


# ============================================================================
# PUBLIC API METHODS - DUST
# ============================================================================

func spawn_dust(pos: Vector2, velocity_x: float = 0.0) -> void:
	## Spawn dust particles at position
	##
	## Parameters:
	##   pos: World position to spawn dust
	##   velocity_x: Horizontal velocity to influence dust direction
	##
	## Use this for landing effects, sliding, or ground interactions
	
	if not enable_dust:
		return
	
	var direction: Vector2 = Vector2(velocity_x, -1.0).normalized()
	_spawn_particle_effect("dust", pos, direction)
	particle_spawned.emit("dust", pos)


# ============================================================================
# INTERNAL METHODS - PARTICLE SPAWNING
# ============================================================================

func _spawn_particle_effect(effect_type: String, pos: Vector2, direction: Vector2) -> void:
	## Internal method to spawn a particle effect
	##
	## Parameters:
	##   effect_type: Type of effect to spawn (must exist in _effect_configs)
	##   pos: World position for the effect
	##   direction: Direction vector for the effect
	
	if not _effect_configs.has(effect_type):
		push_warning("ParticleManager: Unknown effect type: " + effect_type)
		return
	
	# Check particle limit
	if _active_particles.size() >= max_active_particles:
		_cleanup_oldest_particle()
	
	var config: Dictionary = _effect_configs[effect_type]
	
	# Create particle system
	var particles: GPUParticles2D = GPUParticles2D.new()
	particles.name = effect_type + "_" + str(Time.get_ticks_msec())
	particles.position = pos
	particles.emitting = false
	particles.one_shot = true
	particles.explosiveness = 1.0  # Emit all at once
	particles.amount = config["amount"]
	particles.lifetime = config["lifetime"]
	particles.local_coords = false
	
	# Create process material
	var material: ParticleProcessMaterial = ParticleProcessMaterial.new()
	
	# Set color
	material.color = config["color"]
	
	# Set initial velocity and spread
	var initial_vel: Vector2 = config["initial_velocity"]
	if direction != Vector2.ZERO:
		# Rotate velocity by direction
		var angle: float = direction.angle()
		initial_vel = initial_vel.rotated(angle)
	
	material.direction = Vector3(initial_vel.x, initial_vel.y, 0)
	material.initial_velocity_min = initial_vel.length() * 0.8
	material.initial_velocity_max = initial_vel.length() * 1.2
	
	# Set spread
	material.spread = config["spread"]
	
	# Set gravity if enabled
	if config["gravity"]:
		material.gravity = Vector3(0, particle_gravity, 0)
	else:
		material.gravity = Vector3.ZERO
	
	# Set scale
	material.scale_min = config["scale"] * 0.8
	material.scale_max = config["scale"] * 1.2
	
	# Add damping for natural slowdown
	material.damping_min = 50.0
	material.damping_max = 100.0
	
	# Fade out over lifetime
	material.color_ramp = _create_fade_gradient()
	
	particles.process_material = material
	
	# Add to scene
	_particle_container.add_child(particles)
	_active_particles.append(particles)
	
	# Start emission
	particles.emitting = true
	
	# Schedule cleanup
	var cleanup_timer: float = config["lifetime"] + 0.5
	await get_tree().create_timer(cleanup_timer).timeout
	_remove_particle_system(particles)


func _create_fade_gradient() -> Gradient:
	## Create a gradient for particle fade-out
	##
	## Returns:
	##   A Gradient that fades particles over their lifetime
	
	var gradient: Gradient = Gradient.new()
	gradient.add_point(0.0, Color(1, 1, 1, 1))  # Full opacity at start
	gradient.add_point(0.7, Color(1, 1, 1, 1))  # Maintain opacity
	gradient.add_point(1.0, Color(1, 1, 1, 0))  # Fade out at end
	return gradient


# ============================================================================
# INTERNAL METHODS - UPDATES
# ============================================================================

func _update_dash_trails(delta: float) -> void:
	## Update dash trail emission
	##
	## Parameters:
	##   delta: Delta time in seconds
	
	if not _is_dashing or not _dash_target:
		return
	
	_dash_trail_timer += delta
	
	if _dash_trail_timer >= dash_trail_interval:
		spawn_dash_trail(_dash_target.global_position)
		_dash_trail_timer = 0.0


func _cleanup_finished_particles() -> void:
	## Remove finished particle systems
	
	var i: int = _active_particles.size() - 1
	while i >= 0:
		var particles: GPUParticles2D = _active_particles[i]
		if not is_instance_valid(particles) or (not particles.emitting and not particles.is_emitting()):
			_active_particles.remove_at(i)
		i -= 1


func _remove_particle_system(particles: GPUParticles2D) -> void:
	## Remove a particle system from tracking and scene
	##
	## Parameters:
	##   particles: The GPUParticles2D node to remove
	
	var idx: int = _active_particles.find(particles)
	if idx >= 0:
		_active_particles.remove_at(idx)
	
	if is_instance_valid(particles):
		particles.queue_free()


func _cleanup_oldest_particle() -> void:
	## Remove the oldest active particle system
	
	if _active_particles.is_empty():
		return
	
	var oldest: GPUParticles2D = _active_particles[0]
	_remove_particle_system(oldest)


# ============================================================================
# PUBLIC API METHODS - CONFIGURATION
# ============================================================================

func add_custom_effect(effect_name: String, config: Dictionary) -> void:
	## Add a custom particle effect configuration
	##
	## Parameters:
	##   effect_name: Unique name for the effect
	##   config: Dictionary with effect parameters
	##
	## Config dictionary should contain:
	##   - color: Color of particles
	##   - lifetime: Duration in seconds
	##   - scale: Size multiplier
	##   - amount: Number of particles
	##   - gravity: Whether to apply gravity
	##   - initial_velocity: Starting velocity as Vector2
	##   - spread: Spread angle in degrees
	##
	## Example:
	##   particle_manager.add_custom_effect("explosion", {
	##       "color": Color.RED,
	##       "lifetime": 1.0,
	##       "scale": 2.0,
	##       "amount": 30,
	##       "gravity": true,
	##       "initial_velocity": Vector2(200, -200),
	##       "spread": 360.0
	##   })
	
	_effect_configs[effect_name] = config


func spawn_custom_effect(effect_name: String, pos: Vector2, direction: Vector2 = Vector2.ZERO) -> void:
	## Spawn a custom particle effect
	##
	## Parameters:
	##   effect_name: Name of the custom effect (must be registered)
	##   pos: World position to spawn effect
	##   direction: Direction vector for the effect
	
	if not _effect_configs.has(effect_name):
		push_warning("ParticleManager: Custom effect not found: " + effect_name)
		return
	
	_spawn_particle_effect(effect_name, pos, direction)
	particle_spawned.emit(effect_name, pos)


func set_effect_enabled(effect_type: String, enabled: bool) -> void:
	## Enable or disable a specific effect type
	##
	## Parameters:
	##   effect_type: "dash_trail", "impact", or "dust"
	##   enabled: true to enable, false to disable
	
	match effect_type:
		"dash_trail":
			enable_dash_trails = enabled
		"impact":
			enable_impacts = enabled
		"dust":
			enable_dust = enabled


func clear_all_particles() -> void:
	## Immediately remove all active particles
	
	for particles in _active_particles:
		if is_instance_valid(particles):
			particles.queue_free()
	
	_active_particles.clear()


# ============================================================================
# HELPER METHODS
# ============================================================================

func get_active_particle_count() -> int:
	## Get the number of currently active particle systems
	##
	## Returns:
	##   Count of active particle systems
	return _active_particles.size()


func is_dashing() -> bool:
	## Check if dash trail is currently active
	##
	## Returns:
	##   true if dash trail is being emitted
	return _is_dashing
