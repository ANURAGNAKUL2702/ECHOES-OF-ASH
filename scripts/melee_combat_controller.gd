extends Node
## A modular melee combat controller for 2D action games in Godot 4.
##
## This controller implements a comprehensive melee combat system with directional attacks,
## combo chains, and modular design. It is independent of player movement and can be easily
## extended with new abilities and attack types.
##
## Features:
## - Directional melee attacks (left/right)
## - 3-hit combo system with reset timer
## - Knockback effects scaled by enemy weight (via Hitbox/Hurtbox)
## - Separate Hitbox and Hurtbox nodes for collision detection
## - No direct dependency on player movement
## - Extensible design for new abilities
##
## Usage:
## 1. Add this node as a child to your player or character
## 2. Add Hitbox nodes as children (one per attack or weapon)
## 3. Add a Hurtbox node to your character for receiving damage
## 4. Call `attack()` method when attack input is detected
## 5. Connect to signals for visual/audio feedback

class_name MeleeCombatController

# ============================================================================
# SIGNALS
# ============================================================================

## Emitted when an attack starts
## Parameters: attack_number (1, 2, or 3 for combo position)
signal attack_started(attack_number: int)

## Emitted when an attack ends
signal attack_ended()

## Emitted when a combo resets
signal combo_reset()

## Emitted when damage is taken
## Parameters: damage (amount of damage)
signal damage_received(damage: float)

# ============================================================================
# COMBAT PARAMETERS
# ============================================================================

## Attack durations for each combo hit
@export var attack_1_duration: float = 0.3
@export var attack_2_duration: float = 0.35
@export var attack_3_duration: float = 0.4

## Time window to continue the combo after an attack ends
@export var combo_window: float = 0.5

## Time before combo resets if no attack is performed
@export var combo_reset_time: float = 1.0

## Damage values for each combo hit
@export var attack_1_damage: float = 10.0
@export var attack_2_damage: float = 15.0
@export var attack_3_damage: float = 25.0

## Knockback force for each combo hit
@export var attack_1_knockback: float = 200.0
@export var attack_2_knockback: float = 300.0
@export var attack_3_knockback: float = 500.0

## Whether combat system is enabled
@export var enabled: bool = true

## Attack range offset from player (for hitbox positioning)
@export var attack_range: float = 40.0

# ============================================================================
# INTERNAL STATE
# ============================================================================

## Current combo position (0 = no combo, 1-3 = combo hits)
var _combo_count: int = 0

## Current attack timer (counts down during attack)
var _attack_timer: float = 0.0

## Combo reset timer (counts down after attack ends)
var _combo_timer: float = 0.0

## Whether an attack is currently active
var _is_attacking: bool = false

## Whether an attack has been queued during current attack
var _attack_queued: bool = false

## Current attack direction (-1 for left, 1 for right)
var _attack_direction: float = 1.0

## Reference to the parent entity
var _parent: Node = null

## Reference to active hitbox nodes (managed dynamically)
var _hitboxes: Array[Hitbox] = []

## Reference to hurtbox (for receiving damage)
var _hurtbox: Hurtbox = null

# ============================================================================
# BUILT-IN METHODS
# ============================================================================

func _ready() -> void:
	## Initialize the combat controller
	
	# Store parent reference
	_parent = get_parent()
	
	# Find and store hitbox references
	_find_hitboxes()
	
	# Find hurtbox reference
	_find_hurtbox()
	
	# Disable all hitboxes initially
	_disable_all_hitboxes()
	
	# Connect to hurtbox damage signal if available
	if _hurtbox:
		_hurtbox.damage_taken.connect(_on_damage_taken)


func _process(delta: float) -> void:
	## Update combat timers and state
	
	_update_attack_timer(delta)
	_update_combo_timer(delta)

# ============================================================================
# PUBLIC API METHODS
# ============================================================================

func attack(direction: float = 0.0) -> bool:
	## Execute a melee attack
	##
	## Parameters:
	##   direction: Attack direction (-1 left, 1 right, 0 auto-detect from parent)
	##
	## Returns:
	##   true if attack was executed, false if attack is not available
	##
	## Note: This method should be called by the input handler,
	## NOT directly from input events. This maintains separation of concerns.
	
	# Check if combat is enabled
	if not enabled:
		return false
	
	# If currently attacking, queue the next attack
	if _is_attacking:
		_attack_queued = true
		return false
	
	# Determine attack direction
	_attack_direction = direction
	if _attack_direction == 0.0:
		# Auto-detect from parent's scale or velocity
		_attack_direction = _get_parent_direction()
	
	# Start the attack
	_start_attack()
	return true


func can_attack() -> bool:
	## Check if an attack can be performed
	##
	## Returns:
	##   true if attack is available (not currently attacking and enabled)
	return enabled and not _is_attacking


func is_attacking() -> bool:
	## Check if an attack is currently in progress
	##
	## Returns:
	##   true if currently attacking
	return _is_attacking


func get_combo_count() -> int:
	## Get the current combo count
	##
	## Returns:
	##   Current combo position (0-3)
	return _combo_count


func reset_combo() -> void:
	## Manually reset the combo chain
	_reset_combo()


func cancel_attack() -> void:
	## Immediately cancel the current attack
	if _is_attacking:
		_end_attack()


func set_enabled(value: bool) -> void:
	## Enable or disable the combat system
	##
	## Parameters:
	##   value: true to enable combat, false to disable
	enabled = value


func get_attack_direction() -> float:
	## Get the current attack direction
	##
	## Returns:
	##   -1 for left, 1 for right, 0 if not attacking
	if _is_attacking:
		return _attack_direction
	return 0.0

# ============================================================================
# INTERNAL METHODS - ATTACK MANAGEMENT
# ============================================================================

func _start_attack() -> void:
	## Start a new attack in the combo chain
	
	# Increment combo count (loop back to 1 after 3)
	_combo_count = (_combo_count % 3) + 1
	
	# Reset combo timer
	_combo_timer = combo_reset_time
	
	# Set attack state
	_is_attacking = true
	_attack_queued = false
	
	# Set attack duration based on combo position
	match _combo_count:
		1:
			_attack_timer = attack_1_duration
			_activate_hitbox(_combo_count, attack_1_damage, attack_1_knockback)
		2:
			_attack_timer = attack_2_duration
			_activate_hitbox(_combo_count, attack_2_damage, attack_2_knockback)
		3:
			_attack_timer = attack_3_duration
			_activate_hitbox(_combo_count, attack_3_damage, attack_3_knockback)
	
	# Emit signal
	attack_started.emit(_combo_count)


func _end_attack() -> void:
	## End the current attack
	
	# Clear attack state
	_is_attacking = false
	_attack_timer = 0.0
	
	# Disable all hitboxes
	_disable_all_hitboxes()
	
	# Start combo window timer
	_combo_timer = combo_window
	
	# Emit signal
	attack_ended.emit()
	
	# Check if attack was queued
	if _attack_queued and enabled:
		# Start the next attack in the combo
		_start_attack()


func _reset_combo() -> void:
	## Reset the combo chain to the beginning
	
	# Only reset if not currently attacking
	if _is_attacking:
		return
	
	# Reset combo state
	_combo_count = 0
	_combo_timer = 0.0
	_attack_queued = false
	
	# Emit signal
	combo_reset.emit()

# ============================================================================
# INTERNAL METHODS - TIMER UPDATES
# ============================================================================

func _update_attack_timer(delta: float) -> void:
	## Update the attack duration timer
	
	if _attack_timer > 0.0:
		_attack_timer -= delta
		if _attack_timer <= 0.0:
			_end_attack()


func _update_combo_timer(delta: float) -> void:
	## Update the combo reset timer
	
	# Only count down if not attacking
	if _is_attacking:
		return
	
	if _combo_timer > 0.0:
		_combo_timer -= delta
		if _combo_timer <= 0.0 and _combo_count > 0:
			_reset_combo()

# ============================================================================
# INTERNAL METHODS - HITBOX MANAGEMENT
# ============================================================================

func _find_hitboxes() -> void:
	## Find all Hitbox children
	
	_hitboxes.clear()
	for child in get_children():
		if child is Hitbox:
			_hitboxes.append(child)


func _find_hurtbox() -> void:
	## Find Hurtbox in parent or children
	
	# Check parent's children
	if _parent:
		for child in _parent.get_children():
			if child is Hurtbox:
				_hurtbox = child
				return
	
	# Check own children
	for child in get_children():
		if child is Hurtbox:
			_hurtbox = child
			return


func _activate_hitbox(combo_position: int, damage: float, knockback: float) -> void:
	## Activate the appropriate hitbox for the current attack
	
	# For now, activate the first hitbox (can be extended for multiple hitboxes)
	if _hitboxes.size() > 0:
		var hitbox: Hitbox = _hitboxes[0]
		hitbox.damage = damage
		hitbox.knockback_force = knockback
		hitbox.set_attack_direction(_attack_direction)
		hitbox.enable()
		
		# Position hitbox based on attack direction
		_position_hitbox(hitbox)


func _disable_all_hitboxes() -> void:
	## Disable all hitboxes
	
	for hitbox in _hitboxes:
		hitbox.disable()


func _position_hitbox(hitbox: Hitbox) -> void:
	## Position the hitbox relative to the parent based on attack direction
	
	if _parent is Node2D:
		var parent_node: Node2D = _parent as Node2D
		hitbox.position.x = attack_range * _attack_direction

# ============================================================================
# INTERNAL METHODS - HELPER FUNCTIONS
# ============================================================================

func _get_parent_direction() -> float:
	## Get the facing direction of the parent entity
	##
	## Returns:
	##   -1 for left, 1 for right
	
	# Try to get direction from parent's scale
	if _parent is Node2D:
		var parent_node: Node2D = _parent as Node2D
		if parent_node.scale.x < 0:
			return -1.0
		else:
			return 1.0
	
	# Try to get direction from parent's velocity
	if _parent is CharacterBody2D:
		var body: CharacterBody2D = _parent as CharacterBody2D
		if body.velocity.x != 0:
			return sign(body.velocity.x)
	
	# Default to right
	return 1.0


func _on_damage_taken(damage: float, knockback_force: float, knockback_direction: Vector2) -> void:
	## Handle damage received by the hurtbox
	
	# Emit damage signal
	damage_received.emit(damage)
	
	# Optional: Cancel attack when hit
	# if _is_attacking:
	# 	cancel_attack()
