extends Node2D

# Constants and variables defining the properties of the slash attack.
# This script handles the mechanics of a slashing ability typically used in melee combat systems.
var level = 1
var slash_range = 200.0  # The effective range of the slash in game units.
var slash_damage = 50  # Damage dealt by each slash.
var slash_cooldown = 0.75  # Time in seconds before the slash can be used again.
var slash_timer = Timer.new()  # Timer to manage the cooldown period between slashes.
var slash_on_cd = false  # Flag to track whether the slash is currently on cooldown.
var last_movement = Vector2(0, 0)  # The last recorded movement direction of the character.

func _ready():
	"""
	Called when the node is added to the scene. This method initializes the timer and sets up the necessary connections.
	This is used to prepare the slash ability for use, including setting up the cooldown timer and ensuring that it is
	ready to handle the timing of the slash ability's availability.
	"""
	add_child(slash_timer)  # Add the timer to the scene tree.
	slash_timer.connect("timeout", Callable(self, "_on_slash_timer_timeout"))  # Connect the timer's timeout signal to its handler.
	setup_slash_properties()  # Setup slash properties based on the current level.

func setup_slash_properties():
	"""
	Configures slash properties based on its current level. Adjusts damage, range, and other relevant parameters.
	"""
	match level:
		1:
			slash_damage = 50
			slash_range = 200.0
			slash_cooldown = 0.75
		2:
			slash_damage = 70
			slash_range = 220.0
			slash_cooldown = 0.65
		3:
			slash_damage = 90
			slash_range = 240.0
			slash_cooldown = 0.55
		4:
			slash_damage = 110
			slash_range = 260.0
			slash_cooldown = 0.45


func _on_slash_timer_timeout():
	"""
	Callback function that resets the cooldown state when the timer runs out.
	This method allows the slash ability to be used again by resetting the cooldown flag once the cooldown period has elapsed.
	"""
	slash_on_cd = false

func slash():
	"""
	Executes the slash attack if it is not on cooldown. This method handles the activation of the slash attack,
	setting up the collision detection, and managing the attack animation. It ensures the attack only proceeds
	if the ability is not on cooldown.
	"""
	if slash_on_cd:
		return  # Prevent the function from continuing if the slash is on cooldown.
	
	slash_on_cd = true  # Set the slash ability as being on cooldown.
	slash_timer.start(slash_cooldown)  # Start the cooldown timer.
	
	# Attempt to find and play the slash animation using the AnimationPlayer node.
	var animation_player = get_node_or_null("AnimationPlayer")
	if animation_player:
		animation_player.play("SLASH")  # Play the slash animation if the AnimationPlayer is found.
	else:
		print("AnimationPlayer not found.")  # Output error message if AnimationPlayer cannot be found.
	
	# Setup the collision detection for the slash using Area2D and CollisionShape2D nodes.
	var collision_area = Area2D.new()  # Create a new Area2D for detecting collisions.
	var collision_shape = CollisionShape2D.new()  # Create a new CollisionShape2D.
	var shape = RectangleShape2D.new()  # Define the shape as a rectangle.
	shape.extents = Vector2(slash_range, 50)  # Set the dimensions of the rectangle.
	collision_shape.shape = shape  # Assign the rectangle shape to the collision shape.
	collision_area.position = global_position + last_movement.normalized() * slash_range / 2  # Calculate the position of the collision area.
	collision_area.add_child(collision_shape)  # Add the collision shape to the collision area.
	add_child(collision_area)  # Add the collision area to the scene tree.
	
	# Detect and process collisions with enemy entities.
	for body in collision_area.get_overlapping_bodies():
		if body.is_in_group("enemies"):  # Check if the collided body is an enemy.
			body.take_damage(slash_damage)  # Apply damage to the enemy.
	
	collision_area.queue_free()  # Remove and clean up the collision area from the scene after checking.


func _on_timer_timeout() -> void:
	pass # Replace with function body.
