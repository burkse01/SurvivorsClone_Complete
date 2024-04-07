extends Node2D


var forcefield_radius_start = 50.0  # Starting radius
var forcefield_radius_end = 800.0  # End radius after animation
var forcefield_expand_duration = 2.0  # Duration for the radius to expand

func _ready():
	create_forcefield_area()

func create_forcefield_area():
	var forcefield_area = Area2D.new()
	forcefield_area.name = "ForcefieldArea"
	forcefield_area.monitoring = true
	
	var collision_shape = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = forcefield_radius_start  # Start with the initial radius
	collision_shape.shape = shape
	
	forcefield_area.add_child(collision_shape)
	add_child(forcefield_area)

	# Create or get a Tween node
	var tween = Tween.new()
	add_child(tween)
	tween.start()

	# Animate the radius of the circle shape from start to end over the specified duration
	tween.interpolate_property(shape, "radius", forcefield_radius_start, forcefield_radius_end, forcefield_expand_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.start()

	# Remember to connect signals if you need to react to the animation ending
