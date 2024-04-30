extends Area2D

# Variables defining the properties of the forcefield's expansion and effect.
var level = 1
var forcefield_radius_start = 50.0  # Initial radius of the forcefield.
var forcefield_radius_end = 800.0  # Final radius of the forcefield after expansion.
var forcefield_expand_duration = 2.0  # Time in seconds for the forcefield to reach its final radius.
var knockback_amount = 100  # Amount of knockback force applied to enemies.
var damage = 30  # Damage applied to each enemy within the forcefield at the end of the expansion.

# Automatically retrieve a reference to the player from the group "player".
@onready var player = get_tree().get_first_node_in_group("player")
@onready var cleanup_timer = Timer.new()  # Create a new Timer node for cleanup.

signal remove_from_array(object)

func _ready():
	"""
	Called when the node is added to the scene. This method initializes the forcefield
	creation and sets up the initial properties and behaviors of the forcefield, including
	its area of effect and interaction with enemy entities.
	"""
	setup_explosion_properties()
	create_forcefield_area()
	add_child(cleanup_timer)
	cleanup_timer.wait_time = 1.3  # Set the cleanup time to match the expansion duration.
	cleanup_timer.one_shot = true
	cleanup_timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	cleanup_timer.start()  # Start the timer when the scene is ready.
	
func setup_explosion_properties():
	"""
	Configures explosion properties based on its current level. Adjusts damage, radius, and other relevant parameters.
	"""
	match level:
		1:
			damage = 30
			forcefield_radius_end = 800.0
			forcefield_expand_duration = 2.0
			var knockback_amount = 100
		2:
			damage = 45
			forcefield_radius_end = 850.0
			forcefield_expand_duration = 2.0
			var knockback_amount = 200
		3:
			damage = 60
			forcefield_radius_end = 900.0
			forcefield_expand_duration = 2.0
			var knockback_amount = 300
		4:
			damage = 75
			forcefield_radius_end = 950.0
			forcefield_expand_duration = 2.0
			var knockback_amount = 400

func create_forcefield_area():
	"""
	Constructs the forcefield area, defines its physical boundaries, and sets up the necessary
	nodes and signals for collision detection and animation.
	"""
	var forcefield_area = Area2D.new()
	forcefield_area.name = "ForcefieldArea"
	forcefield_area.monitoring = true  # Enable monitoring to detect body entries.
	
	var collision_shape = CollisionShape2D.new()
	var shape = CircleShape2D.new()
	shape.radius = forcefield_radius_start  # Initialize with the starting radius.
	collision_shape.shape = shape
	
	forcefield_area.add_child(collision_shape)
	add_child(forcefield_area)
	
	# Connect the signal for body entry to handle interactions with enemies.
	forcefield_area.connect("body_entered", Callable(self, "_on_ForcefieldArea_body_entered"))
	
	var animation_player = get_node_or_null("AnimationPlayer")
	if animation_player:
		animation_player.play("EXPLOSION")
		
	# Deferred tween initialization to ensure it's in the scene tree.
	call_deferred("initialize_tween", forcefield_area, shape)
	
	
	# Setup and start a tween for smooth radius expansion animation.
func initialize_tween(forcefield_area, shape):
	var tween = forcefield_area.create_tween()
	tween.tween_property(shape, "radius", forcefield_radius_end, forcefield_expand_duration)
	tween.connect("tween_completed", Callable(self, "_on_Tween_tween_completed"))
	tween.play()

func _on_ForcefieldArea_body_entered(body):
	"""
	Called when a body enters the forcefield area. This method checks if the body belongs
	to the 'enemies' group and applies damage if it does, also applying knockback.
	"""
	if body.is_in_group("enemies"):
		var knockback_direction = (body.global_position - global_position).normalized()  # Calculate knockback direction away from the explosion center
		body._on_hurt_box_hurt(damage, knockback_direction, knockback_amount)  # Use the enemy's method to apply damage and knockback

func _on_Tween_tween_completed(tween: Tween, key: String, forcefield_area: Area2D):
	forcefield_area.queue_free()

func _process(delta):
	if player:
		global_position = player.global_position  # Update position each frame to stay with the player

func _on_timer_timeout() -> void:
	emit_signal("remove_from_array",self)
	queue_free()
