extends Node2D

# Slash
var slash_range = 200.0
var slash_damage = 50
var slash_cooldown = 0.75  # Cooldown in seconds
var slash_timer = Timer.new()  # Timer for cooldown
var spell_1_on_cd = false  # Cooldown flag
var last_movement = Vector2(0, 0)  # Default direction

func _ready():
	add_child(slash_timer)
	slash_timer.connect("timeout", Callable(self, "_on_slash_timer_timeout"))

func _on_slash_timer_timeout():
	spell_1_on_cd = false

func slash():
	if spell_1_on_cd:
		return
	spell_1_on_cd = true
	slash_timer.start(slash_cooldown)
	
	# Animation for slash
	# walk.play("SLASH")

	# Collision detection
	var collision_area = Area2D.new()
	var collision_shape = CollisionShape2D.new()
	var shape = RectangleShape2D.new()
	shape.extents = Vector2(slash_range, 50)
	collision_shape.shape = shape
	collision_area.position = position + last_movement.normalized() * slash_range / 2
	collision_area.add_child(collision_shape)
	add_child(collision_area)
	
	# Check for collisions with enemies
	for body in collision_area.get_overlapping_bodies():
		if body.is_in_group("enemies"):
			body.take_damage(slash_damage)
	collision_area.queue_free()  # Clean up
