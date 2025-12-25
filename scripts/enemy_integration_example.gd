extends Node2D
## Example integration script for enemy AI
##
## This script demonstrates how to use the EnemyAI controller
## by connecting to its signals and responding to state changes.
##
## Usage:
## Attach this script to a scene containing an EnemyAI node.

# Reference to the enemy AI node
@onready var enemy: EnemyAI = $Enemy
@onready var state_label: Label = $Enemy/StateLabel

func _ready() -> void:
	## Initialize and connect to enemy signals
	
	if not enemy:
		push_error("Enemy node not found!")
		return
	
	# Connect to enemy signals
	enemy.target_detected.connect(_on_enemy_target_detected)
	enemy.target_lost.connect(_on_enemy_target_lost)
	enemy.attack_ready.connect(_on_enemy_attack_ready)
	enemy.stunned.connect(_on_enemy_stunned)
	enemy.died.connect(_on_enemy_died)


func _process(_delta: float) -> void:
	## Update debug display
	
	if enemy and state_label:
		state_label.text = enemy.get_state_name()


func _on_enemy_target_detected(target: Node2D) -> void:
	## Called when enemy detects a target
	print("Enemy detected target: ", target.name)
	# Example: Play detection sound
	# $DetectionSound.play()


func _on_enemy_target_lost() -> void:
	## Called when enemy loses sight of target
	print("Enemy lost target")
	# Example: Play alert sound
	# $AlertSound.play()


func _on_enemy_attack_ready(target: Node2D) -> void:
	## Called when enemy is ready to attack
	## This is where you integrate combat logic
	print("Enemy attacking: ", target.name)
	
	# Example combat integration:
	# if target.has_method("take_damage"):
	#     target.take_damage(10)
	# $AttackSound.play()
	# $AttackAnimation.play()


func _on_enemy_stunned() -> void:
	## Called when enemy is stunned
	print("Enemy stunned!")
	# Example: Play stun effect
	# $StunParticles.emitting = true
	# $StunSound.play()


func _on_enemy_died() -> void:
	## Called when enemy dies
	print("Enemy died!")
	# Example: Play death animation and clean up
	# $DeathAnimation.play()
	# await $DeathAnimation.animation_finished
	# queue_free()


# ============================================================================
# EXAMPLE EXTERNAL INTERACTION
# ============================================================================

func damage_enemy(amount: int) -> void:
	## Example method showing how external systems can interact with the enemy
	## This would be called by player attacks or other damage sources
	
	print("Enemy took ", amount, " damage")
	
	# Example: Check if damage should stun
	if amount >= 20 and randf() > 0.5:
		enemy.stun()
	
	# Example: Check if damage should kill
	# if enemy_health <= 0:
	#     enemy.kill()
