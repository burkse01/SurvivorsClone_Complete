extends Area2D

# Constants and variables defining the properties of the slash attack.
var level = 1
var slash_range = 200.0  # The effective range of the slash in game units.
var slash_damage = 50  # Damage dealt by each slash.
var slash_speed = 400  # Speed at which the slash moves.
var slash_knockback_amount = 100  # Amount of knockback force applied to enemies.
var last_movement = Vector2.ZERO  # The last recorded movement direction of the character.

@onready var player = get_tree().get_first_node_in_group("player")
@onready var cleanup_timer = Timer.new()

signal hit_enemy(enemy, knockback_amount, knockback_direction)  # This signal will be emitted when an enemy is hit.

signal remove_from_array(object)

func _ready():
	setup_slash_properties()
	execute_slash()
	add_child(cleanup_timer)
	cleanup_timer.wait_time = .3 # Adjust the cleanup delay as needed
	cleanup_timer.one_shot = true
	cleanup_timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	cleanup_timer.start()

func setup_slash_properties():
	match level:
		1:
			slash_damage = 50
			slash_range = 200.0
			slash_speed = 400
			slash_knockback_amount = 100
		2:
			slash_damage = 70
			slash_range = 220.0
			slash_speed = 450
			slash_knockback_amount = 120
		3:
			slash_damage = 90
			slash_range = 240.0
			slash_speed = 500
			slash_knockback_amount = 140
		4:
			slash_damage = 110
			slash_range = 260.0
			slash_speed = 550
			slash_knockback_amount = 160

func execute_slash():
	# Attempt to find and play the slash animation using the AnimationPlayer node.
	var animation_player = get_node_or_null("AnimationPlayer")
	if animation_player:
		animation_player.play("SLASH")

	# Set up the collision detection for the slash.
	var collision_shape = CollisionShape2D.new()
	var shape = CapsuleShape2D.new()
	shape.height = 50
	shape.radius = slash_range / 2
	collision_shape.shape = shape
	
	var collision_area = Area2D.new()
	collision_area.add_child(collision_shape)
	add_child(collision_area)
	collision_area.global_position = global_position + last_movement.normalized() * slash_range / 2
	
	collision_area.connect("area_entered", Callable(self, "_on_area_entered"))

func _process(delta):
	if player:
		global_position = player.global_position  # Update position each frame to stay with the player

func _on_area_entered(area: Area2D):
	if area.is_in_group("enemies"):
		var enemy = area.get_parent() if area.get_parent() else area
		# Directly call the damage and knockback handling function
		var knockback_direction = last_movement.normalized() if last_movement != Vector2.ZERO else Vector2.UP
		var knockback_force = knockback_direction * slash_knockback_amount
		enemy._on_hurt_box_hurt(slash_damage, knockback_direction, knockback_force.length())
		emit_signal("hit_enemy", enemy, slash_knockback_amount, knockback_direction)
		

func _on_timer_timeout():
	emit_signal("remove_from_array",self)
	queue_free()
