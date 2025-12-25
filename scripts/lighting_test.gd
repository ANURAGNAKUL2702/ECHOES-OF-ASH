extends Node2D
## Test script for the LightingSystem
##
## This script demonstrates and tests all features of the LightingSystem:
## - Player-following light
## - Flickering environmental lights
## - Fog layers
## - Runtime configuration

# ============================================================================
# CONFIGURATION
# ============================================================================

@export var lighting_system: LightingSystem
@export var player: Node2D

# ============================================================================
# INTERNAL STATE
# ============================================================================

var _test_lights: Array[PointLight2D] = []

# ============================================================================
# BUILT-IN METHODS
# ============================================================================

func _ready() -> void:
	## Initialize the test scene
	
	# Auto-detect if not assigned
	if not lighting_system:
		lighting_system = $LightingSystem
	
	if not player:
		player = $Player
	
	# Setup player light
	if lighting_system and player:
		lighting_system.setup_player_light(player)
		print("Lighting System: Player light configured")
	
	# Add some flickering lights
	_setup_test_lights()
	
	print("=== Lighting System Test ===")
	print("Controls:")
	print("  1 - Toggle player light")
	print("  2 - Toggle flickering lights")
	print("  3 - Toggle fog")
	print("  4 - Cycle player light color")
	print("  5 - Add random flickering light")
	print("  + - Increase player light brightness")
	print("  - - Decrease player light brightness")
	print("  WASD/Arrows - Move player")


func _input(event: InputEvent) -> void:
	## Handle test controls
	
	if not event is InputEventKey or not event.pressed:
		return
	
	var key_event: InputEventKey = event as InputEventKey
	
	match key_event.keycode:
		KEY_1:
			_toggle_player_light()
		KEY_2:
			_toggle_flickering_lights()
		KEY_3:
			_toggle_fog()
		KEY_4:
			_cycle_player_light_color()
		KEY_5:
			_add_random_light()
		KEY_EQUAL, KEY_KP_ADD:  # + key
			_adjust_player_light_brightness(0.1)
		KEY_MINUS, KEY_KP_SUBTRACT:  # - key
			_adjust_player_light_brightness(-0.1)


# ============================================================================
# SETUP METHODS
# ============================================================================

func _setup_test_lights() -> void:
	## Add some test flickering lights around the scene
	
	if not lighting_system:
		return
	
	# Add lights at various positions
	var light_positions: Array[Vector2] = [
		Vector2(300, 200),
		Vector2(800, 200),
		Vector2(150, 500),
		Vector2(650, 500),
		Vector2(1100, 500)
	]
	
	for pos in light_positions:
		var light: PointLight2D = lighting_system.add_flickering_light(pos)
		_test_lights.append(light)
	
	print("Added ", _test_lights.size(), " flickering lights")


# ============================================================================
# TEST METHODS
# ============================================================================

func _toggle_player_light() -> void:
	## Toggle player light on/off
	
	if not lighting_system:
		return
	
	var is_enabled: bool = lighting_system.get_player_light() != null and lighting_system.get_player_light().enabled
	lighting_system.set_player_light_enabled(not is_enabled)
	print("Player light: ", "OFF" if is_enabled else "ON")


func _toggle_flickering_lights() -> void:
	## Toggle all flickering lights on/off
	
	if _test_lights.is_empty():
		return
	
	var is_enabled: bool = _test_lights[0].enabled
	for light in _test_lights:
		light.enabled = not is_enabled
	
	print("Flickering lights: ", "OFF" if is_enabled else "ON")


func _toggle_fog() -> void:
	## Toggle fog layers on/off
	
	if not lighting_system:
		return
	
	lighting_system.set_fog_enabled(not lighting_system.enable_fog)
	print("Fog: ", "ON" if lighting_system.enable_fog else "OFF")


func _cycle_player_light_color() -> void:
	## Cycle through different light colors
	
	if not lighting_system:
		return
	
	var colors: Array[Color] = [
		Color(1.0, 0.9, 0.7, 1.0),   # Warm white
		Color(0.7, 0.9, 1.0, 1.0),   # Cool white
		Color(1.0, 0.8, 0.5, 1.0),   # Orange
		Color(0.5, 1.0, 0.8, 1.0),   # Cyan
		Color(1.0, 0.5, 1.0, 1.0)    # Magenta
	]
	
	var current_color: Color = lighting_system.player_light_color
	var current_index: int = 0
	
	# Find current color index
	for i in range(colors.size()):
		if current_color.is_equal_approx(colors[i]):
			current_index = i
			break
	
	# Move to next color
	var next_index: int = (current_index + 1) % colors.size()
	lighting_system.set_player_light_color(colors[next_index])
	print("Player light color changed")


func _add_random_light() -> void:
	## Add a flickering light at random position
	
	if not lighting_system:
		return
	
	var random_pos: Vector2 = Vector2(
		randf_range(100, 1180),
		randf_range(100, 620)
	)
	
	var light: PointLight2D = lighting_system.add_flickering_light(random_pos)
	_test_lights.append(light)
	print("Added light at ", random_pos)


func _adjust_player_light_brightness(delta: float) -> void:
	## Adjust player light brightness
	
	if not lighting_system:
		return
	
	var new_energy: float = lighting_system.player_light_energy + delta
	lighting_system.set_player_light_energy(new_energy)
	print("Player light energy: ", lighting_system.player_light_energy)
