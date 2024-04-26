extends Area2D

# This script handles the dashing mechanics of a player or an entity, including movement and effects.
var level = 1
var dash_speed = 700  # The speed at which the dash occurs.
var dash_distance = 500  # The total distance covered by the dash.
var damage = 20  # The amount of damage inflicted by the dash if it hits enemies.
var knockback_amount = 400  # The force of knockback applied to enemies hit by the dash.
var dash_duration = 1.5  # The duration in seconds the dash lasts.

# Preloads the trail effect resource to be used during the dash.
var trail_effect = preload("res://Player/Attack/DASH.tscn")

# Reference to the player node, assumes the player is part of a group named 'player'.
@onready var player = get_tree().get_nodes_in_group("player")[0]

# Signal declaration to notify when the dash object should be removed from arrays managing game objects.
signal remove_from_array(object)

func _ready():
	"""
	Initializes the dash effect as soon as the node enters the scene. This function automatically triggers
	the start of the dash movement and effect creation.
	"""
	setup_dash_properties()  # Configure dash properties based on the current level.
	start_dash()
	
func setup_dash_properties():
	"""
	Configures dash properties based on its current level. Adjusts speed, distance, damage, and other relevant parameters.
	"""
	match level:
		1:
			dash_speed = 700
			dash_distance = 500
			damage = 20
			knockback_amount = 400
			dash_duration = 1.5
		2:
			dash_speed = 700
			dash_distance = 550
			damage = 30
			knockback_amount = 450
			dash_duration = 1.5
		3:
			dash_speed = 700
			dash_distance = 550
			damage = 40
			knockback_amount = 500
			dash_duration = 1.5
		4:
			dash_speed = 700
			dash_distance = 550
			damage = 50
			knockback_amount = 550
			dash_duration = 1.5

func start_dash():
	"""
	Handles the logic to start the dash movement using a Tween for smooth animation. This function calculates
	the target position based on the dash distance and initializes the trail effect.
	"""
	# Calculate the dash target position based on the player's last movement direction.
	var dash_target = global_position + player.last_movement.normalized() * dash_distance
	# Create a new Tween node and configure it to animate the global position of this node.
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "global_position", global_position, dash_target, dash_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	# Connect the 'tween_completed' signal to a method that handles the end of the dash.
	tween.connect("tween_completed", Callable(self, "_on_tween_completed"))
	tween.start()
	
	# Instantiate the trail effect and position it at the current position to follow the dash.
	var trail_instance = trail_effect.instance()
	trail_instance.global_position = global_position
	add_child(trail_instance)

func _on_tween_completed(object, key):
	"""
	Called when the Tween animation completes. This method is responsible for checking collision with enemies,
	applying damage and knockback, and then cleaning up the dash node.
	"""
	# Logic to check for collisions with enemies and apply damage and knockback could be implemented here.
	emit_signal("remove_from_array", self)  # Notify interested parties that the dash is complete.
	queue_free()  # Remove this node from the scene.
