extends CharacterBody2D
## Example integration of MeleeCombatController with a Player2D character.
##
## This script demonstrates how to integrate the modular melee combat controller
## with an existing player controller. It shows the clean separation of concerns
## between movement and combat systems.
##
## Features Demonstrated:
## - Input handling for combat (separate from movement)
## - Combining movement and combat without tight coupling
## - Responding to combat signals for visual/audio feedback
## - Querying combat state for gameplay logic
##
## Usage:
## 1. This script extends Player2D (or use with CharacterBody2D)
## 2. Add a MeleeCombatController node as a child
## 3. Add Hitbox node(s) as children of MeleeCombatController
## 4. Add a Hurtbox node as a child of this character
## 5. Configure attack parameters in the inspector
##
## Note: This is a demonstration script. For production use, consider
## creating a dedicated input handler or state machine that coordinates
## between movement and combat systems.

# ============================================================================
# CHILD NODE REFERENCES
# ============================================================================

## Reference to the combat controller
@onready var combat_controller: MeleeCombatController = $MeleeCombatController

# ============================================================================
# COMBAT INTEGRATION PARAMETERS
# ============================================================================

## Whether to allow movement during attacks
@export var can_move_while_attacking: bool = true

## Movement speed multiplier during attacks (0.0 to 1.0)
@export var attack_movement_penalty: float = 0.5

# ============================================================================
# BUILT-IN METHODS
# ============================================================================

func _ready() -> void:
	## Initialize the combat integration
	super._ready()
	
	# Connect to combat signals for feedback
	if combat_controller:
		combat_controller.attack_started.connect(_on_attack_started)
		combat_controller.attack_ended.connect(_on_attack_ended)
		combat_controller.combo_reset.connect(_on_combo_reset)
		combat_controller.damage_received.connect(_on_damage_received)


func _physics_process(delta: float) -> void:
	## Handle input and physics
	
	# Handle combat input
	_handle_combat_input()
	
	# Call parent movement logic
	super._physics_process(delta)
	
	# Apply combat movement penalty if attacking
	if combat_controller and combat_controller.is_attacking():
		if not can_move_while_attacking:
			velocity.x = 0.0
		else:
			velocity.x *= attack_movement_penalty

# ============================================================================
# INPUT HANDLING
# ============================================================================

func _handle_combat_input() -> void:
	## Handle combat-related input
	## This demonstrates the separation of concerns: combat input is handled
	## separately from movement input
	
	# Check if combat controller exists
	if not combat_controller:
		return
	
	# Handle attack input
	if Input.is_action_just_pressed("attack"):
		# Get current facing direction from movement
		var attack_direction: float = get_movement_direction()
		if attack_direction == 0.0:
			# If not moving, use last facing direction or default to right
			attack_direction = 1.0
		
		# Execute attack
		combat_controller.attack(attack_direction)

# ============================================================================
# SIGNAL HANDLERS
# ============================================================================

func _on_attack_started(attack_number: int) -> void:
	## Handle attack started event
	## This is where you would add visual/audio feedback
	
	print("Attack ", attack_number, " started! (Combo: ", combat_controller.get_combo_count(), ")")
	
	# Example: Play attack animation
	# animation_player.play("attack_" + str(attack_number))
	
	# Example: Play attack sound
	# audio_player.play()
	
	# Example: Create attack VFX
	# spawn_attack_effect(combat_controller.get_attack_direction())


func _on_attack_ended() -> void:
	## Handle attack ended event
	
	print("Attack ended")
	
	# Example: Transition back to idle/run animation
	# animation_player.play("idle")


func _on_combo_reset() -> void:
	## Handle combo reset event
	
	print("Combo reset!")
	
	# Example: Reset combo UI indicator
	# ui_manager.reset_combo_display()


func _on_damage_received(damage: float) -> void:
	## Handle damage received event
	
	print("Took ", damage, " damage!")
	
	# Example: Update health
	# health -= damage
	# if health <= 0:
	# 	die()
	
	# Example: Play hurt animation
	# animation_player.play("hurt")
	
	# Example: Play hurt sound
	# hurt_audio.play()
	
	# Example: Screen shake
	# camera.shake(0.3, 10.0)

# ============================================================================
# PUBLIC API EXTENSIONS
# ============================================================================

func can_perform_action() -> bool:
	## Check if the player can perform other actions
	## This is useful for preventing certain actions during attacks
	##
	## Returns:
	##   true if player can perform actions
	
	if combat_controller and combat_controller.is_attacking():
		return false
	
	return true


func get_combat_state() -> String:
	## Get a human-readable combat state
	##
	## Returns:
	##   String describing current combat state
	
	if not combat_controller:
		return "No Combat Controller"
	
	if combat_controller.is_attacking():
		return "Attacking (Combo: " + str(combat_controller.get_combo_count()) + ")"
	elif combat_controller.get_combo_count() > 0:
		return "Combo Active (" + str(combat_controller.get_combo_count()) + ")"
	else:
		return "Ready"

# ============================================================================
# HELPER METHODS
# ============================================================================

func get_movement_direction() -> float:
	## Get the current movement direction from velocity
	## This allows combat to use movement direction without tight coupling
	##
	## Returns:
	##   -1 for left, 1 for right, 0 for no movement
	
	if velocity.x != 0:
		return sign(velocity.x)
	return 0.0
