extends Node
## Example integration script for the DashModule
##
## This script demonstrates how to integrate the DashModule with a player controller.
## It shows proper usage of the dash API and separation of concerns.
##
## Prerequisites:
## - "dash" input action must be defined in Project Settings -> Input Map
## - "move_left" and "move_right" input actions (typically already defined for player movement)
##
## Usage:
## 1. Add this script to your player scene
## 2. Add a DashModule node as a child
## 3. Assign the DashModule node to the @export variable in the inspector
## 4. Configure input actions in Project Settings if not already present
## 5. The script will handle dash input and call the module's dash() method

class_name DashIntegrationExample

# ============================================================================
# CONFIGURATION
# ============================================================================

## Reference to the DashModule node
@export var dash_module: DashModule

## Reference to the player CharacterBody2D
@export var player: CharacterBody2D

## Input action name for dash (configure in project settings)
@export var dash_input_action: String = "dash"

# ============================================================================
# BUILT-IN METHODS
# ============================================================================

func _ready() -> void:
	## Initialize and validate references
	
	# Auto-detect player if not set
	if not player:
		player = get_parent() as CharacterBody2D
		if not player:
			push_error("DashIntegrationExample: Could not find CharacterBody2D player")
			return
	
	# Auto-detect dash module if not set
	if not dash_module:
		dash_module = get_node_or_null("DashModule") as DashModule
		if not dash_module:
			push_error("DashIntegrationExample: Could not find DashModule")
			return
	
	# Connect to dash signals for feedback
	if dash_module:
		dash_module.dash_started.connect(_on_dash_started)
		dash_module.dash_ended.connect(_on_dash_ended)
		dash_module.dash_ready.connect(_on_dash_ready)


func _process(_delta: float) -> void:
	## Handle dash input
	
	# Check if dash input was pressed
	if Input.is_action_just_pressed(dash_input_action):
		_attempt_dash()


# ============================================================================
# DASH METHODS
# ============================================================================

func _attempt_dash() -> void:
	## Attempt to execute a dash
	##
	## This method checks if dash is available and executes it
	## Direction is auto-detected from player movement
	
	if not dash_module or not player:
		return
	
	# Check if dash is available
	if not dash_module.can_dash():
		# Optional: Play "can't dash" sound or visual feedback
		return
	
	# Get player's current movement direction
	var dash_direction: float = 0.0
	
	# Try to get direction from current velocity
	if player.velocity.x != 0:
		dash_direction = sign(player.velocity.x)
	else:
		# Fallback: get direction from input
		dash_direction = Input.get_axis("move_left", "move_right")
		if dash_direction == 0.0:
			# Default to facing direction or right
			dash_direction = 1.0
	
	# Execute the dash
	var success: bool = dash_module.dash(player, dash_direction)
	
	if success:
		# Optional: Add additional effects here
		# - Play dash sound
		# - Spawn dash particles
		# - Screen shake
		pass


# ============================================================================
# SIGNAL HANDLERS
# ============================================================================

func _on_dash_started() -> void:
	## Called when dash starts
	##
	## Use this to trigger visual/audio feedback
	print("Dash started!")
	# Optional: Play dash sound, spawn particles, etc.


func _on_dash_ended() -> void:
	## Called when dash ends
	##
	## Use this to trigger end-of-dash effects
	print("Dash ended!")
	# Optional: Play landing sound, spawn dust particles, etc.


func _on_dash_ready() -> void:
	## Called when dash comes off cooldown
	##
	## Use this to update UI or play ready sound
	print("Dash ready!")
	# Optional: Update dash UI indicator, play ready sound, etc.

# ============================================================================
# PUBLIC API METHODS
# ============================================================================

func unlock_dash() -> void:
	## Unlock the dash ability (for progression)
	if dash_module:
		dash_module.set_enabled(true)
		print("Dash ability unlocked!")


func lock_dash() -> void:
	## Lock the dash ability
	if dash_module:
		dash_module.set_enabled(false)
		print("Dash ability locked!")


func is_dashing() -> bool:
	## Check if currently dashing
	if dash_module:
		return dash_module.is_dashing()
	return false


func is_invincible() -> bool:
	## Check if player has invincibility frames
	if dash_module:
		return dash_module.is_invincible()
	return false
