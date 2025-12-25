extends Node
## Integration example for LightingSystem and ParticleManager with DashModule
##
## This script demonstrates how to integrate the atmospheric systems with
## the existing DashModule to create a cohesive visual experience.
##
## Features demonstrated:
## - Dash trail particles during dash
## - Dust particles on landing
## - Impact particles on collision (optional combat integration)
## - Player light that follows the player
##
## Prerequisites:
## - LightingSystem node in the scene
## - ParticleManager node in the scene
## - DashModule node (if using dash integration)
## - Player CharacterBody2D node
##
## Usage:
## 1. Add this script to your game scene
## 2. Assign references in the inspector or let auto-detection work
## 3. The script will automatically integrate all systems

class_name AtmosphericIntegration

# ============================================================================
# CONFIGURATION
# ============================================================================

## Reference to the LightingSystem
@export var lighting_system: LightingSystem

## Reference to the ParticleManager
@export var particle_manager: ParticleManager

## Reference to the DashModule (optional)
@export var dash_module: DashModule

## Reference to the player
@export var player: CharacterBody2D

## Enable automatic dust on landing
@export var auto_dust_on_landing: bool = true

## Minimum fall velocity to trigger landing dust
@export var landing_velocity_threshold: float = 200.0

# ============================================================================
# INTERNAL STATE
# ============================================================================

## Track if player was airborne last frame
var _was_airborne: bool = false

## Track if player is currently dashing
var _is_dashing: bool = false

# ============================================================================
# BUILT-IN METHODS
# ============================================================================

func _ready() -> void:
	## Initialize the atmospheric integration
	
	# Auto-detect components if not assigned
	_auto_detect_components()
	
	# Setup lighting
	if lighting_system and player:
		lighting_system.setup_player_light(player)
		print("Atmospheric Integration: Lighting configured")
	
	# Connect to dash signals if dash module exists
	if dash_module:
		dash_module.dash_started.connect(_on_dash_started)
		dash_module.dash_ended.connect(_on_dash_ended)
		print("Atmospheric Integration: Dash integration connected")
	
	print("Atmospheric Integration: Initialized")


func _physics_process(_delta: float) -> void:
	## Monitor player state for automatic effects
	
	if not player:
		return
	
	# Check for landing
	if auto_dust_on_landing:
		_check_landing()


# ============================================================================
# AUTO-DETECTION METHODS
# ============================================================================

func _auto_detect_components() -> void:
	## Automatically detect components if not assigned
	
	# Try to find in parent hierarchy
	var parent: Node = get_parent()
	
	if not lighting_system:
		lighting_system = _find_node_of_type(parent, "LightingSystem") as LightingSystem
	
	if not particle_manager:
		particle_manager = _find_node_of_type(parent, "ParticleManager") as ParticleManager
	
	if not dash_module:
		dash_module = _find_node_of_type(parent, "DashModule") as DashModule
	
	if not player:
		# Look for player in "player" group
		var players: Array[Node] = get_tree().get_nodes_in_group("player")
		if not players.is_empty():
			player = players[0] as CharacterBody2D


func _find_node_of_type(node: Node, type_name: String) -> Node:
	## Recursively find a node with a specific class name
	##
	## Parameters:
	##   node: Starting node for search
	##   type_name: Class name to search for
	##
	## Returns:
	##   The found node or null
	
	if node == null:
		return null
	
	# Check current node by comparing script class name
	if node.get_script():
		var script: Script = node.get_script()
		# Check global name if available (for class_name declarations)
		var global_name: String = script.get_global_name()
		if global_name != "" and global_name == type_name:
			return node
		# Fallback: check script path filename (for scripts without class_name)
		if script.resource_path != "":
			var script_name: String = script.resource_path.get_file().get_basename()
			# Convert PascalCase to snake_case for comparison
			var snake_case_name: String = _to_snake_case(type_name)
			if script_name == snake_case_name:
				return node
	
	# Check children recursively
	for child in node.get_children():
		var result: Node = _find_node_of_type(child, type_name)
		if result:
			return result
	
	return null


func _to_snake_case(text: String) -> String:
	## Convert PascalCase to snake_case
	##
	## Parameters:
	##   text: PascalCase string to convert
	##
	## Returns:
	##   snake_case version of the string
	
	var result: String = ""
	for i in range(text.length()):
		var c: String = text[i]
		if c == c.to_upper() and i > 0:
			result += "_"
		result += c.to_lower()
	return result


# ============================================================================
# LANDING DETECTION
# ============================================================================

func _check_landing() -> void:
	## Check if player just landed and spawn dust
	
	var is_airborne: bool = not player.is_on_floor()
	
	# Detect landing transition
	if _was_airborne and not is_airborne:
		# Player just landed
		var landing_velocity: float = abs(player.velocity.y)
		
		if landing_velocity >= landing_velocity_threshold:
			_spawn_landing_dust()
	
	_was_airborne = is_airborne


func _spawn_landing_dust() -> void:
	## Spawn dust particles at player's feet on landing
	
	if not particle_manager or not player:
		return
	
	# Calculate dust position (at player's feet)
	var dust_position: Vector2 = player.global_position
	dust_position.y += 32  # Offset to feet (adjust based on player size)
	
	# Spawn dust with player's horizontal velocity
	particle_manager.spawn_dust(dust_position, player.velocity.x)


# ============================================================================
# DASH INTEGRATION
# ============================================================================

func _on_dash_started() -> void:
	## Called when dash starts - begin trail particles
	
	if not particle_manager or not player:
		return
	
	_is_dashing = true
	particle_manager.start_dash_trail(player)


func _on_dash_ended() -> void:
	## Called when dash ends - stop trail and spawn ending dust
	
	if not particle_manager:
		return
	
	_is_dashing = false
	particle_manager.stop_dash_trail()
	
	# Optional: spawn dust cloud at end of dash
	if player:
		var dust_position: Vector2 = player.global_position
		particle_manager.spawn_dust(dust_position, player.velocity.x)


# ============================================================================
# PUBLIC API METHODS
# ============================================================================

func spawn_impact_at_player(direction: Vector2 = Vector2.RIGHT) -> void:
	## Spawn impact particles at player position
	##
	## Parameters:
	##   direction: Direction of the impact
	##
	## Use this for combat hits or collisions
	
	if not particle_manager or not player:
		return
	
	particle_manager.spawn_impact(player.global_position, direction)


func spawn_custom_effect(effect_name: String, position: Vector2, direction: Vector2 = Vector2.ZERO) -> void:
	## Spawn a custom particle effect
	##
	## Parameters:
	##   effect_name: Name of the custom effect
	##   position: World position for the effect
	##   direction: Direction vector for the effect
	
	if not particle_manager:
		return
	
	particle_manager.spawn_custom_effect(effect_name, position, direction)


func set_player_light_intensity(intensity: float) -> void:
	## Adjust player light brightness (useful for dark areas)
	##
	## Parameters:
	##   intensity: Light energy level (0.0 to 2.0)
	
	if lighting_system:
		lighting_system.set_player_light_energy(intensity)


func add_environmental_light(position: Vector2, color: Color = Color.WHITE) -> PointLight2D:
	## Add a flickering environmental light
	##
	## Parameters:
	##   position: World position for the light
	##   color: Color of the light
	##
	## Returns:
	##   The created PointLight2D node
	
	if lighting_system:
		return lighting_system.add_flickering_light(position, color)
	return null


func is_player_dashing() -> bool:
	## Check if player is currently dashing
	##
	## Returns:
	##   true if dash is active
	return _is_dashing
