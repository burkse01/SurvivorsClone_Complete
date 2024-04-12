extends Node2D

var forcefield_radius_start = 50.0  # Starting radius
var forcefield_radius_end = 800.0  # End radius after animation
var forcefield_expand_duration = 2.0  # Duration for the radius to expand
var damage = 30  # Damage dealt to enemies within the final radius

@onready var player = get_tree().get_first_node_in_group("player")

func _ready():
	create_forcefield_area()

func create_forcefield_area():
	var forcefield_area = Area2D.new()
	forcefield_area.name = "ForcefieldArea"
	forcefield_area.position = player.global_position  # Position at the player's location
	forcefield_area.monitoring = true
	
	var collision_shape = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = forcefield_radius_start  # Start with the initial radius
	collision_shape.shape = shape
	
	forcefield_area.add_child(collision_shape)
	add_child(forcefield_area)

	# Connect signal to detect enemies entering the forcefield
	forcefield_area.connect("body_entered", self, "_on_ForcefieldArea_body_entered")
	
	# Create a Tween node to animate the expansion
	var tween = Tween.new()
	add_child(tween)
	
	# Animate the radius of the circle shape from start to end over the specified duration
	tween.interpolate_property(shape, "radius", forcefield_radius_start, forcefield_radius_end, forcefield_expand_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.connect("tween_completed", self, "_on_Tween_tween_completed", [forcefield_area])
	tween.start()

func _on_ForcefieldArea_body_entered(body):
	if body.is_in_group("enemies"):
		# Assume enemies have a method to handle being hit by an explosion
		body.take_damage(damage)

func _on_Tween_tween_completed(object, key, forcefield_area):
	# Once the animation completes, you might want to remove the forcefield or apply additional effects
	forcefield_area.queue_free()  # Clean up the forcefield_area
