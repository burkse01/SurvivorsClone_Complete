extends Area2D

var dash_speed = 700
var dash_distance = 500
var damage = 20
var knockback_amount = 400
var dash_duration = 0.5  # How long the dash lasts in seconds

var trail_effect = preload("res://Player/Attack/DASH.tscn")  # Load your trail effect scene

@onready var player = get_tree().get_nodes_in_group("player")[0]
signal remove_from_array(object)

func _ready():
	start_dash()

func start_dash():
	var dash_target = global_position + player.last_movement.normalized() * dash_distance
	var tween = Tween.new()
	add_child(tween)
	tween.interpolate_property(self, "global_position", global_position, dash_target, dash_duration, Tween.TRANS_LINEAR, Tween.EASE_IN_OUT)
	
	# Correctly use Callable for the method connection
	tween.connect("tween_completed", Callable(self, "_on_tween_completed"))
	tween.start()
	
	# Create a trail effect
	var trail_instance = trail_effect.instance()
	trail_instance.global_position = global_position  # Start the trail at the current position
	add_child(trail_instance)

func _on_tween_completed(object, key):
	# This method is called when the tween animation is completed
	# Perform the check for enemies and apply damage and knockback here
	emit_signal("remove_from_array", self)
	queue_free()  # Clean up after the dash is complete
