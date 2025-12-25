extends Area2D
## A hitbox node for detecting when an attack lands on a target.
##
## This node represents the offensive collision area of an attack.
## When it overlaps with a Hurtbox, it triggers damage on the target.
## It is designed to be modular and reusable for any attack type.
##
## Features:
## - Configurable damage value
## - Configurable knockback force
## - Can be enabled/disabled for attack timing
## - Emits signal when hitting a target
##
## Usage:
## 1. Add this as a child of your attack or weapon node
## 2. Configure damage and knockback in the inspector
## 3. Add a CollisionShape2D child with the attack area
## 4. Enable the hitbox when the attack is active
## 5. Disable the hitbox when the attack ends

class_name Hitbox

# ============================================================================
# SIGNALS
# ============================================================================

## Emitted when this hitbox hits a hurtbox
## Parameters: hurtbox (the Hurtbox that was hit)
signal hit_landed(hurtbox: Hurtbox)

# ============================================================================
# HITBOX PARAMETERS
# ============================================================================

## Damage dealt by this hitbox
@export var damage: float = 10.0

## Knockback force applied to the target
@export var knockback_force: float = 300.0

## Whether this hitbox is currently active
## When disabled, the hitbox won't detect collisions
@export var active: bool = true

## Attack direction (-1 for left, 1 for right, 0 for no direction)
## Used to determine knockback direction
var attack_direction: float = 1.0

# ============================================================================
# BUILT-IN METHODS
# ============================================================================

func _ready() -> void:
	## Initialize the hitbox
	## Connect to area_entered signal to detect hurtboxes
	
	# Set up collision detection
	area_entered.connect(_on_area_entered)
	
	# Set collision layers
	# Layer 3 is for hitboxes
	collision_layer = 4  # Binary: 100 (layer 3)
	# Mask 4 is for hurtboxes
	collision_mask = 8   # Binary: 1000 (layer 4)


func _on_area_entered(area: Area2D) -> void:
	## Handle collision with another area
	## Check if it's a hurtbox and apply damage
	
	# Only process if this hitbox is active
	if not active:
		return
	
	# Check if the area is a Hurtbox
	if area is Hurtbox:
		var hurtbox: Hurtbox = area as Hurtbox
		
		# Calculate knockback direction
		var knockback_direction: Vector2 = Vector2(attack_direction, -0.5).normalized()
		
		# Apply damage to the hurtbox
		hurtbox.take_damage(damage, knockback_force, knockback_direction)
		
		# Emit signal
		hit_landed.emit(hurtbox)

# ============================================================================
# PUBLIC API METHODS
# ============================================================================

func enable() -> void:
	## Enable this hitbox to detect collisions
	active = true
	monitoring = true
	monitorable = true


func disable() -> void:
	## Disable this hitbox from detecting collisions
	active = false
	monitoring = false
	monitorable = false


func set_attack_direction(direction: float) -> void:
	## Set the direction of the attack for knockback calculation
	##
	## Parameters:
	##   direction: -1 for left, 1 for right
	attack_direction = direction
