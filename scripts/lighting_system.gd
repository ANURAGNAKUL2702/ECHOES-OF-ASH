extends Node2D
## A modular atmospheric lighting system for 2D games in Godot 4.
##
## This system provides multiple lighting features for creating atmospheric 2D environments:
## - Player-following light source with smooth movement
## - Flickering environmental lights for ambiance
## - Fog layers for depth and atmosphere
## - Performance-safe defaults optimized for various hardware
##
## Features:
## - Smooth camera-relative lighting that follows the player
## - Configurable flickering lights with natural variation
## - Layered fog system with parallax-like depth
## - Easy-to-configure export parameters
## - Minimal performance impact with optimized defaults
##
## Usage:
## 1. Add this node to your scene
## 2. Configure export parameters in the inspector
## 3. Call setup_player_light(player) to attach the player light
## 4. Use add_flickering_light(position, color) to add environmental lights
## 5. Fog layers are automatically created based on configuration

class_name LightingSystem

# ============================================================================
# SIGNALS
# ============================================================================

## Emitted when the lighting system is fully initialized
signal lighting_initialized()

# ============================================================================
# PLAYER LIGHT PARAMETERS
# ============================================================================

## Enable player-following light
@export var enable_player_light: bool = true

## Energy/brightness of the player light (0.0 to 2.0)
@export_range(0.0, 2.0) var player_light_energy: float = 1.0

## Scale/size of the player light
@export var player_light_scale: Vector2 = Vector2(1.5, 1.5)

## Color of the player light
@export var player_light_color: Color = Color(1.0, 0.9, 0.7, 1.0)  # Warm white

## Height offset of the player light
@export var player_light_offset: Vector2 = Vector2(0, -20)

## Smoothing speed for player light follow (0 = instant)
@export var player_light_smoothing: float = 10.0

## Z-index for player light layer
@export var player_light_z_index: int = 10

# ============================================================================
# FLICKERING LIGHT PARAMETERS
# ============================================================================

## Enable flickering environmental lights
@export var enable_flickering_lights: bool = true

## Base energy for flickering lights
@export_range(0.0, 2.0) var flicker_base_energy: float = 0.8

## Variation in flickering intensity (0.0 to 1.0)
@export_range(0.0, 1.0) var flicker_intensity: float = 0.3

## Speed of flickering animation
@export var flicker_speed: float = 3.0

## Default color for flickering lights
@export var flicker_default_color: Color = Color(1.0, 0.8, 0.5, 1.0)  # Torch-like

## Default scale for flickering lights
@export var flicker_default_scale: Vector2 = Vector2(2.0, 2.0)

# ============================================================================
# FOG PARAMETERS
# ============================================================================

## Enable fog layers
@export var enable_fog: bool = true

## Number of fog layers (1-3 recommended for performance)
@export_range(1, 5) var fog_layer_count: int = 2

## Base color of the fog
@export var fog_color: Color = Color(0.15, 0.15, 0.2, 0.3)  # Dark atmospheric fog

## Z-index for fog rendering (negative to render behind gameplay)
@export var fog_z_index: int = -5

## Scale of fog particles/texture
@export var fog_scale: float = 2.0

## Movement speed of fog layers
@export var fog_movement_speed: float = 10.0

# ============================================================================
# INTERNAL STATE
# ============================================================================

## Reference to the player light node
var _player_light: PointLight2D = null

## Reference to the player node being followed
var _player_target: Node2D = null

## Array of flickering light data
var _flickering_lights: Array[Dictionary] = []

## Array of fog layer nodes
var _fog_layers: Array[CanvasModulate] = []

## Time accumulator for flickering animation
var _flicker_time: float = 0.0

## Container for all lights
var _lights_container: Node2D = null

## Container for fog layers
var _fog_container: Node2D = null

# ============================================================================
# BUILT-IN METHODS
# ============================================================================

func _ready() -> void:
	## Initialize the lighting system
	_setup_containers()
	_setup_fog_layers()
	lighting_initialized.emit()


func _process(delta: float) -> void:
	## Update lighting effects each frame
	_update_player_light(delta)
	_update_flickering_lights(delta)


# ============================================================================
# SETUP METHODS
# ============================================================================

func _setup_containers() -> void:
	## Create container nodes for organization
	
	# Container for all lights
	_lights_container = Node2D.new()
	_lights_container.name = "Lights"
	add_child(_lights_container)
	
	# Container for fog
	_fog_container = Node2D.new()
	_fog_container.name = "Fog"
	_fog_container.z_index = fog_z_index
	add_child(_fog_container)


func _setup_fog_layers() -> void:
	## Create fog layers for atmospheric effect
	
	if not enable_fog:
		return
	
	for i in range(fog_layer_count):
		var fog_layer: ColorRect = ColorRect.new()
		fog_layer.name = "FogLayer" + str(i)
		fog_layer.color = fog_color
		
		# Make fog layers semi-transparent and vary by layer
		var alpha_variation: float = 1.0 - (float(i) / float(fog_layer_count) * 0.5)
		fog_layer.color.a = fog_color.a * alpha_variation
		
		# Set size to cover viewport (will be adjusted in viewport)
		fog_layer.set_anchors_preset(Control.PRESET_FULL_RECT)
		fog_layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		
		_fog_container.add_child(fog_layer)


func setup_player_light(player: Node2D) -> void:
	## Configure the player-following light
	##
	## Parameters:
	##   player: The Node2D to follow (typically the player CharacterBody2D)
	##
	## Call this method after the lighting system is ready to attach
	## the light to a specific player node
	
	if not enable_player_light:
		return
	
	_player_target = player
	
	# Create player light if it doesn't exist
	if not _player_light:
		_player_light = PointLight2D.new()
		_player_light.name = "PlayerLight"
		_lights_container.add_child(_player_light)
	
	# Configure player light properties
	_player_light.enabled = true
	_player_light.energy = player_light_energy
	_player_light.texture_scale = player_light_scale.x  # PointLight2D uses float
	_player_light.color = player_light_color
	_player_light.z_index = player_light_z_index
	
	# Set initial position
	if _player_target:
		_player_light.global_position = _player_target.global_position + player_light_offset


# ============================================================================
# PUBLIC API METHODS - FLICKERING LIGHTS
# ============================================================================

func add_flickering_light(pos: Vector2, color: Color = flicker_default_color, scale_factor: float = 1.0) -> PointLight2D:
	## Add a new flickering environmental light
	##
	## Parameters:
	##   pos: World position for the light
	##   color: Color of the light (default: torch-like orange)
	##   scale_factor: Size multiplier for the light
	##
	## Returns:
	##   The created PointLight2D node for further customization
	##
	## Example:
	##   var torch = lighting_system.add_flickering_light(Vector2(100, 100))
	
	if not enable_flickering_lights:
		return null
	
	# Create the light node
	var light: PointLight2D = PointLight2D.new()
	light.name = "FlickeringLight" + str(_flickering_lights.size())
	light.position = pos
	light.color = color
	light.energy = flicker_base_energy
	light.texture_scale = flicker_default_scale.x * scale_factor
	light.enabled = true
	
	_lights_container.add_child(light)
	
	# Store light data for flickering animation
	var light_data: Dictionary = {
		"light": light,
		"base_energy": flicker_base_energy,
		"phase_offset": randf() * TAU,  # Random phase for natural variation
		"flicker_frequency": randf_range(0.8, 1.2)  # Slight frequency variation
	}
	_flickering_lights.append(light_data)
	
	return light


func remove_flickering_light(light: PointLight2D) -> void:
	## Remove a flickering light from the system
	##
	## Parameters:
	##   light: The PointLight2D node to remove
	
	for i in range(_flickering_lights.size()):
		if _flickering_lights[i]["light"] == light:
			_flickering_lights.remove_at(i)
			light.queue_free()
			break


# ============================================================================
# PUBLIC API METHODS - PLAYER LIGHT
# ============================================================================

func set_player_light_enabled(enabled: bool) -> void:
	## Enable or disable the player light
	##
	## Parameters:
	##   enabled: true to enable, false to disable
	
	if _player_light:
		_player_light.enabled = enabled


func set_player_light_energy(energy: float) -> void:
	## Set the brightness of the player light
	##
	## Parameters:
	##   energy: Light energy (0.0 to 2.0)
	
	player_light_energy = clamp(energy, 0.0, 2.0)
	if _player_light:
		_player_light.energy = player_light_energy


func set_player_light_color(color: Color) -> void:
	## Set the color of the player light
	##
	## Parameters:
	##   color: New light color
	
	player_light_color = color
	if _player_light:
		_player_light.color = color


# ============================================================================
# PUBLIC API METHODS - FOG
# ============================================================================

func set_fog_enabled(enabled: bool) -> void:
	## Enable or disable fog layers
	##
	## Parameters:
	##   enabled: true to show fog, false to hide
	
	enable_fog = enabled
	if _fog_container:
		_fog_container.visible = enabled


func set_fog_color(color: Color) -> void:
	## Set the color of fog layers
	##
	## Parameters:
	##   color: New fog color (alpha determines transparency)
	
	fog_color = color
	
	# Update existing fog layers
	for i in range(_fog_container.get_child_count()):
		var fog_layer: ColorRect = _fog_container.get_child(i) as ColorRect
		if fog_layer:
			var alpha_variation: float = 1.0 - (float(i) / float(fog_layer_count) * 0.5)
			fog_layer.color = color
			fog_layer.color.a = color.a * alpha_variation


# ============================================================================
# UPDATE METHODS
# ============================================================================

func _update_player_light(delta: float) -> void:
	## Update player light position to follow player
	##
	## Parameters:
	##   delta: Delta time in seconds
	
	if not _player_light or not _player_target:
		return
	
	var target_position: Vector2 = _player_target.global_position + player_light_offset
	
	if player_light_smoothing > 0.0:
		# Smooth follow
		_player_light.global_position = _player_light.global_position.lerp(
			target_position, 
			delta * player_light_smoothing
		)
	else:
		# Instant follow
		_player_light.global_position = target_position


func _update_flickering_lights(delta: float) -> void:
	## Update flickering animation for environmental lights
	##
	## Parameters:
	##   delta: Delta time in seconds
	
	if not enable_flickering_lights or _flickering_lights.is_empty():
		return
	
	_flicker_time += delta * flicker_speed
	
	for light_data in _flickering_lights:
		var light: PointLight2D = light_data["light"]
		var base_energy: float = light_data["base_energy"]
		var phase: float = light_data["phase_offset"]
		var frequency: float = light_data["flicker_frequency"]
		
		# Use sine wave for smooth, natural flickering
		var flicker: float = sin(_flicker_time * frequency + phase) * 0.5 + 0.5
		var energy_variation: float = flicker * flicker_intensity
		
		light.energy = base_energy + (energy_variation * base_energy)


# ============================================================================
# HELPER METHODS
# ============================================================================

func get_player_light() -> PointLight2D:
	## Get reference to the player light node
	##
	## Returns:
	##   The PointLight2D following the player, or null if not created
	return _player_light


func get_flickering_light_count() -> int:
	## Get the number of active flickering lights
	##
	## Returns:
	##   Count of flickering lights in the system
	return _flickering_lights.size()


func clear_all_flickering_lights() -> void:
	## Remove all flickering lights from the system
	
	for light_data in _flickering_lights:
		var light: PointLight2D = light_data["light"]
		if light:
			light.queue_free()
	
	_flickering_lights.clear()
