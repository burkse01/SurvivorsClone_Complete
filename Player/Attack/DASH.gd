extends Area2D

var dash_speed = 700
var dash_distance = 500
var damage = 20
var knockback_amount = 400
var dash_duration = 0.5  # How long the dash lasts in seconds

var trail_effect = preload("res://path_to_trail_effect.tscn")  # Load your trail effect scene

@onready var player = get_tree().get_first_node_in_group("player")
signal remove_from_array(object)

func _ready():
	start_dash()

func start_dash():
	var dash_target = global_position + player.last_movement.normalized() * dash_distance
	var tween = create_tween()
	tween.tween_property(self, "global_position", dash_target, dash_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	tween.tween_callback(self, "on_dash_complete")
	tween.play()
	
	# Optionally, create a trail effect
	var trail_instance = trail_effect.instance()
	trail_instance.global_position = global_position  # Start the trail at the current position
	add_child(trail_instance)

func on_dash_complete():
	# Detect enemies in the final area (you might need an Area2D node with a collision shape for this)
	var enemies = get_overlapping_bodies()  # Assuming this is an Area2D node
	for enemy in enemies:
		if enemy.is_in_group("enemies"):  # Make sure to only affect enemies
			enemy.take_damage(damage)
			enemy.apply_knockback(player.last_movement.normalized(), knockback_amount)
			# Implement any additional effects on enemies here
	
	# The dash is complete, you might want to return control to the player or continue with the game logic
	emit_signal("remove_from_array", self)

func _on_timer_timeout():
	queue_free()  # Cleanup, make sure the node is removed after the ability is executed
