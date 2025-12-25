extends Node2D
## Test scene script for Enemy AI demonstration
##
## This script updates the debug UI and logs enemy AI events

@onready var enemy: EnemyAI = $Enemy
@onready var debug_label: Label = $DebugUI/Label

func _ready() -> void:
	## Initialize test scene
	
	if not enemy:
		push_error("Enemy node not found!")
		return
	
	# Connect to enemy signals for debugging
	enemy.target_detected.connect(_on_enemy_target_detected)
	enemy.target_lost.connect(_on_enemy_target_lost)
	enemy.attack_ready.connect(_on_enemy_attack_ready)
	enemy.stunned.connect(_on_enemy_stunned)
	enemy.died.connect(_on_enemy_died)
	
	print("Enemy AI Test Scene initialized")
	print("Enemy starting state: ", enemy.get_state_name())


func _process(_delta: float) -> void:
	## Update debug display
	
	if enemy and debug_label:
		var target_text = "None"
		if enemy.get_target():
			target_text = enemy.get_target().name
		
		debug_label.text = "Enemy AI Test Scene\n"
		debug_label.text += "State: %s\n" % enemy.get_state_name()
		debug_label.text += "Target: %s\n" % target_text
		debug_label.text += "Position: (%.0f, %.0f)" % [enemy.global_position.x, enemy.global_position.y]


func _on_enemy_target_detected(target: Node2D) -> void:
	## Called when enemy detects a target
	print("[Enemy] Target detected: ", target.name)


func _on_enemy_target_lost() -> void:
	## Called when enemy loses sight of target
	print("[Enemy] Target lost")


func _on_enemy_attack_ready(target: Node2D) -> void:
	## Called when enemy is ready to attack
	print("[Enemy] Attacking: ", target.name)
	
	# Example: This is where you would integrate combat logic
	# if target.has_method("take_damage"):
	#     target.take_damage(10)


func _on_enemy_stunned() -> void:
	## Called when enemy is stunned
	print("[Enemy] Stunned!")


func _on_enemy_died() -> void:
	## Called when enemy dies
	print("[Enemy] Died!")


# ============================================================================
# INPUT HANDLING FOR TESTING
# ============================================================================

func _unhandled_input(event: InputEvent) -> void:
	## Handle test inputs
	
	# Press '1' to stun enemy
	if event.is_action_pressed("ui_text_backspace"):
		print("Test: Stunning enemy")
		enemy.stun()
	
	# Press '2' to kill enemy
	if event.is_action_pressed("ui_text_delete"):
		print("Test: Killing enemy")
		enemy.kill()
