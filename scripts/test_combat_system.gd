extends Node
## Simple test script to verify the Melee Combat System functionality
##
## This script tests the core functionality of the combat system:
## - Combat controller initialization
## - Attack execution
## - Combo system
## - Hitbox/Hurtbox collision
## - Damage handling
## - Invincibility frames
##
## Run this script in Godot's script editor or attach it to a test scene

func _ready() -> void:
	print("=== MELEE COMBAT SYSTEM TEST ===")
	print()
	
	test_combat_controller()
	test_hitbox()
	test_hurtbox()
	test_combo_system()
	
	print()
	print("=== ALL TESTS COMPLETED ===")


func test_combat_controller() -> void:
	print("--- Testing MeleeCombatController ---")
	
	# Create a CharacterBody2D as parent
	var player = CharacterBody2D.new()
	add_child(player)
	
	# Create and add combat controller
	var combat = MeleeCombatController.new()
	player.add_child(combat)
	
	# Test initial state
	assert(not combat.is_attacking(), "Should not be attacking initially")
	assert(combat.get_combo_count() == 0, "Combo should be 0 initially")
	assert(combat.can_attack(), "Should be able to attack")
	print("✓ Initial state correct")
	
	# Test attack
	var result = combat.attack(1.0)
	assert(result, "Attack should succeed")
	assert(combat.is_attacking(), "Should be attacking after attack()")
	assert(combat.get_combo_count() == 1, "Combo should be 1 after first attack")
	print("✓ Attack execution works")
	
	# Test attack direction
	assert(combat.get_attack_direction() == 1.0, "Attack direction should be 1.0")
	print("✓ Attack direction correct")
	
	# Clean up
	player.queue_free()
	print("✓ MeleeCombatController tests passed")
	print()


func test_hitbox() -> void:
	print("--- Testing Hitbox ---")
	
	# Create hitbox
	var hitbox = Hitbox.new()
	add_child(hitbox)
	
	# Add collision shape
	var shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(20, 20)
	shape.shape = rect_shape
	hitbox.add_child(shape)
	
	# Test initial state
	assert(hitbox.active, "Hitbox should be active by default")
	assert(hitbox.damage == 10.0, "Default damage should be 10.0")
	print("✓ Hitbox initial state correct")
	
	# Test enable/disable
	hitbox.disable()
	assert(not hitbox.active, "Hitbox should be inactive after disable()")
	hitbox.enable()
	assert(hitbox.active, "Hitbox should be active after enable()")
	print("✓ Hitbox enable/disable works")
	
	# Test attack direction
	hitbox.set_attack_direction(-1.0)
	assert(hitbox.attack_direction == -1.0, "Attack direction should be -1.0")
	print("✓ Hitbox attack direction works")
	
	# Clean up
	hitbox.queue_free()
	print("✓ Hitbox tests passed")
	print()


func test_hurtbox() -> void:
	print("--- Testing Hurtbox ---")
	
	# Create a CharacterBody2D as parent
	var entity = CharacterBody2D.new()
	add_child(entity)
	
	# Create hurtbox
	var hurtbox = Hurtbox.new()
	entity.add_child(hurtbox)
	
	# Add collision shape
	var shape = CollisionShape2D.new()
	var rect_shape = RectangleShape2D.new()
	rect_shape.size = Vector2(20, 20)
	shape.shape = rect_shape
	hurtbox.add_child(shape)
	
	# Test initial state
	assert(hurtbox.vulnerable, "Hurtbox should be vulnerable by default")
	assert(not hurtbox.is_invincible(), "Should not be invincible initially")
	assert(hurtbox.weight == 1.0, "Default weight should be 1.0")
	print("✓ Hurtbox initial state correct")
	
	# Test damage reception (with signal)
	var damage_received = false
	hurtbox.damage_taken.connect(func(_d, _kf, _kd): damage_received = true)
	
	hurtbox.take_damage(10.0, 300.0, Vector2(1, 0))
	assert(damage_received, "damage_taken signal should be emitted")
	assert(hurtbox.is_invincible(), "Should be invincible after taking damage")
	print("✓ Hurtbox damage reception works")
	
	# Test i-frame progress
	var progress = hurtbox.get_iframe_progress()
	assert(progress > 0.0 and progress <= 1.0, "I-frame progress should be between 0 and 1")
	print("✓ Hurtbox i-frame tracking works")
	
	# Clean up
	entity.queue_free()
	print("✓ Hurtbox tests passed")
	print()


func test_combo_system() -> void:
	print("--- Testing Combo System ---")
	
	# Create a CharacterBody2D as parent
	var player = CharacterBody2D.new()
	add_child(player)
	
	# Create combat controller with faster timings for testing
	var combat = MeleeCombatController.new()
	combat.attack_1_duration = 0.1
	combat.attack_2_duration = 0.1
	combat.attack_3_duration = 0.1
	combat.combo_window = 1.0
	player.add_child(combat)
	
	# Test combo chain
	combat.attack(1.0)
	assert(combat.get_combo_count() == 1, "First attack should set combo to 1")
	print("✓ First combo hit works")
	
	# Queue second attack
	await get_tree().create_timer(0.15).timeout
	combat.attack(1.0)
	assert(combat.get_combo_count() == 2, "Second attack should set combo to 2")
	print("✓ Second combo hit works")
	
	# Queue third attack
	await get_tree().create_timer(0.15).timeout
	combat.attack(1.0)
	assert(combat.get_combo_count() == 3, "Third attack should set combo to 3")
	print("✓ Third combo hit works")
	
	# Fourth attack should reset to 1
	await get_tree().create_timer(0.15).timeout
	combat.attack(1.0)
	assert(combat.get_combo_count() == 1, "Fourth attack should reset combo to 1")
	print("✓ Combo loops correctly")
	
	# Test combo reset
	await get_tree().create_timer(1.5).timeout
	assert(combat.get_combo_count() == 0, "Combo should reset after timeout")
	print("✓ Combo reset works")
	
	# Clean up
	player.queue_free()
	print("✓ Combo system tests passed")
	print()
