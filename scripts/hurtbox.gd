extends Area2D
## A hurtbox node for receiving damage from attacks.
##
## This node represents the defensive collision area of an entity.
## When overlapped by a Hitbox, it receives damage and can trigger
## invincibility frames to prevent multiple hits.
##
## Features:
## - Invincibility frames (i-frames) after taking damage
## - Knockback application scaled by entity weight
## - Configurable i-frame duration
## - Emits signals for damage events
##
## Usage:
## 1. Add this as a child of your character/enemy node
## 2. Configure i-frame duration and weight in the inspector
## 3. Add a CollisionShape2D child covering the vulnerable area
## 4. Connect to damage_taken signal to handle damage effects

class_name Hurtbox

# ============================================================================
# SIGNALS
# ============================================================================

## Emitted when damage is taken
## Parameters: damage (amount of damage), knockback_force (force applied), knockback_direction (direction of knockback)
signal damage_taken(damage: float, knockback_force: float, knockback_direction: Vector2)

## Emitted when invincibility frames start
signal iframe_started()

## Emitted when invincibility frames end
signal iframe_ended()

# ============================================================================
# HURTBOX PARAMETERS
# ============================================================================

## Duration of invincibility frames in seconds
## Set to 0 to disable i-frames
@export var iframe_duration: float = 0.5

## Weight of the entity (affects knockback scaling)
## Higher weight = less knockback
## 1.0 is default, 0.5 is lighter (more knockback), 2.0 is heavier (less knockback)
@export var weight: float = 1.0

## Whether this hurtbox is currently vulnerable
## When false, damage is ignored
@export var vulnerable: bool = true

# ============================================================================
# INTERNAL STATE
# ============================================================================

## Current invincibility timer
var _iframe_timer: float = 0.0

## Reference to the parent entity (for knockback application)
var _parent: Node = null

# ============================================================================
# BUILT-IN METHODS
# ============================================================================

func _ready() -> void:
	## Initialize the hurtbox
	
	# Set collision layers
	# Layer 4 is for hurtboxes
	collision_layer = 8   # Binary: 1000 (layer 4)
	# Mask 3 is for hitboxes
	collision_mask = 4    # Binary: 100 (layer 3)
	
	# Store parent reference
	_parent = get_parent()


func _process(delta: float) -> void:
	## Update invincibility frames timer
	
	if _iframe_timer > 0.0:
		_iframe_timer -= delta
		if _iframe_timer <= 0.0:
			# I-frames ended
			vulnerable = true
			iframe_ended.emit()

# ============================================================================
# PUBLIC API METHODS
# ============================================================================

func take_damage(damage: float, knockback_force: float, knockback_direction: Vector2) -> void:
	## Receive damage from a hitbox
	##
	## Parameters:
	##   damage: Amount of damage to take
	##   knockback_force: Base knockback force
	##   knockback_direction: Direction of knockback (should be normalized)
	
	# Check if vulnerable (not in i-frames)
	if not vulnerable or _iframe_timer > 0.0:
		return
	
	# Apply scaled knockback based on weight
	var scaled_knockback: float = knockback_force / weight
	
	# Start invincibility frames
	if iframe_duration > 0.0:
		_iframe_timer = iframe_duration
		vulnerable = false
		iframe_started.emit()
	
	# Apply knockback to parent if it's a CharacterBody2D
	if _parent is CharacterBody2D:
		var body: CharacterBody2D = _parent as CharacterBody2D
		body.velocity = knockback_direction * scaled_knockback
	
	# Emit damage signal
	damage_taken.emit(damage, scaled_knockback, knockback_direction)


func is_invincible() -> bool:
	## Check if invincibility frames are currently active
	##
	## Returns:
	##   true if i-frames are active
	return _iframe_timer > 0.0


func get_iframe_progress() -> float:
	## Get the current i-frame progress as a value from 0.0 to 1.0
	##
	## Returns:
	##   0.0 when vulnerable, 1.0 when i-frames just started
	if iframe_duration <= 0.0:
		return 0.0
	return clamp(_iframe_timer / iframe_duration, 0.0, 1.0)


func set_vulnerable(value: bool) -> void:
	## Manually set vulnerability state
	##
	## Parameters:
	##   value: true to make vulnerable, false to make invincible
	##
	## Note: This overrides i-frame state
	vulnerable = value
	if not value:
		_iframe_timer = iframe_duration
