extends Area2D

# Variables defining the properties of the forcefield's effect.
var level = 1
var knockback_amount = 400  # Amount of knockback force applied to enemies.
var damage = 30  # Damage applied to each enemy within the forcefield.

var attack_size = 1.0  # Modifies the scale of the explosion based on player's spell size.

var target = Vector2.ZERO
var angle = Vector2.ZERO

# Automatically retrieve a reference to the player from the group "player".
@onready var player = get_tree().get_first_node_in_group("player")
@onready var cleanup_timer = Timer.new()  # Create a new Timer node for cleanup.
@onready var sprite = $Explosion  # Adjust the path to your sprite node if necessary

signal remove_from_array(object)

func _ready():
	"""
	Called when the node is added to the scene. This method initializes the forcefield
	creation and sets up the initial properties and behaviors of the forcefield, including
	its area of effect and interaction with enemy entities.
	"""
	setup_explosion_properties() # Ensure the sprite remains upright
	create_forcefield_area()
	add_child(cleanup_timer)
	cleanup_timer.wait_time = 1.1  # Cleanup after set duration.
	cleanup_timer.one_shot = true
	cleanup_timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	cleanup_timer.start()  # Start the timer when the scene is ready.

func setup_explosion_properties():
	"""
	Configures explosion properties based on its current level. Adjusts damage and other relevant parameters.
	"""
	level = player.explosion_level
	angle = global_position.direction_to(target)
	rotation = 0
	
	match level:
		1:
			damage = 30
			knockback_amount = 400
			attack_size = 1.0 * (1 + player.spell_size)
		2:
			damage = 45
			knockback_amount = 500
			attack_size = 1.0 * (1 + player.spell_size)
		3:
			damage = 60
			knockback_amount = 600
			attack_size = 1.0 * (1 + player.spell_size)
		4:
			damage = 75
			knockback_amount = 700
			attack_size = 1.0 * (1 + player.spell_size)
		
	
func create_forcefield_area():
	"""
	Constructs the forcefield area, defines its physical boundaries, and sets up the necessary
	nodes and signals for collision detection.
	"""
	var animation_player = get_node_or_null("AnimationPlayer")
	if animation_player:
		animation_player.play("EXPLOSION")
	# Connect the signal for body entry to handle interactions with enemies.
	
func _process(delta):
	if player:
		global_position = player.global_position  # Update position each frame to stay with the player

func _on_timer_timeout():
	"""
	Called when the timer times out to remove the forcefield from the scene.
	"""
	emit_signal("remove_from_array", self)
	queue_free()
