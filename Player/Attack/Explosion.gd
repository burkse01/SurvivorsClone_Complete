extends Node2D

# Variables defining the properties of the forcefield's expansion and effect.
var level = 1
var forcefield_radius_start = 50.0  # Initial radius of the forcefield.
var forcefield_radius_end = 800.0  # Final radius of the forcefield after expansion.
var forcefield_expand_duration = 2.0  # Time in seconds for the forcefield to reach its final radius.
var damage = 30  # Damage applied to each enemy within the forcefield at the end of the expansion.

# Automatically retrieve a reference to the player from the group "player".
@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	"""
	Called when the node is added to the scene. This method initializes the forcefield
	creation and sets up the initial properties and behaviors of the forcefield, including
	its area of effect and interaction with enemy entities.
	"""
	setup_explosion_properties()
	create_forcefield_area()
	
func setup_explosion_properties():
	"""
	Configures explosion properties based on its current level. Adjusts damage, radius, and other relevant parameters.
	"""
	match level:
		1:
			damage = 30
			forcefield_radius_end = 800.0
			forcefield_expand_duration = 2.0
		2:
			damage = 45
			forcefield_radius_end = 850.0
			forcefield_expand_duration = 1.8
		3:
			damage = 60
			forcefield_radius_end = 900.0
			forcefield_expand_duration = 1.6
		4:
			damage = 75
			forcefield_radius_end = 950.0
			forcefield_expand_duration = 1.4

func create_forcefield_area():
	"""
	Constructs the forcefield area, defines its physical boundaries, and sets up the necessary
	nodes and signals for collision detection and animation.
	"""
	var forcefield_area = Area2D.new()
	forcefield_area.name = "ForcefieldArea"
	forcefield_area.position = player.global_position  # Set the position at the player's location.
	forcefield_area.monitoring = true  # Enable monitoring to detect body entries.
	
	var collision_shape = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = forcefield_radius_start  # Initialize with the starting radius.
	collision_shape.shape = shape
	
	forcefield_area.add_child(collision_shape)
	add_child(forcefield_area)
	
	# Connect the signal for body entry to handle interactions with enemies.
	forcefield_area.connect("body_entered", Callable(self, "_on_ForcefieldArea_body_entered"))
	
	# Setup and start a tween for smooth radius expansion animation.
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(shape, "radius", forcefield_radius_start, forcefield_radius_end, forcefield_expand_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.connect("tween_completed", Callable(self, "_on_Tween_tween_completed"))
	
	# Keep a reference to the forcefield area for later access, particularly for cleanup.
	self.forcefield_area = forcefield_area
	tween.start()

func _on_ForcefieldArea_body_entered(body):
	"""
	Called when a body enters the forcefield area. This method checks if the body belongs
	to the 'enemies' group and applies damage if it does.
	"""
	if body.is_in_group("enemies"):
		body.take_damage(damage)  # Apply the predefined damage to the enemy.

func _on_Tween_tween_completed(object, key):
	"""
	Called when the tween animation completes. This method handles the cleanup of the
	forcefield area by freeing the associated Area2D node from memory.
	"""
	# Cleanup the forcefield area by freeing it, which removes it from the scene.
	self.forcefield_area.queue_free()
