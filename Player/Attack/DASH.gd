extends Area2D

# Constants and variables defining the properties of the dash.
var level = 1
var speed = 200  # Speed at which the dash occurs.
var damage = 10  # Damage dealt by the dash.
var knockback_amount = 300  # Knockback force applied by the dash.
var max_distance = 200  # Maximum distance the dash can travel from the start position.
var attack_size = 1.0  # Modifies the scale of the explosion based on player's spell size.

var target = Vector2.ZERO
var angle = Vector2.ZERO

var start_position = Vector2.ZERO
var moving = false  # Controls whether the dash is actively moving.
var last_flip_state = false  # This tracks the last state of sprite flipping.

@onready var player = get_tree().get_first_node_in_group("player")
@onready var animation_player = get_node_or_null("AnimationPlayer")
@onready var sprite = $Sprite2D  # Adjust the path to your sprite node if necessary
signal remove_from_array(object)

func _ready():
	start_position = global_position
	setup_dash_properties()
	if animation_player:
		animation_player.play("DASH")
		moving = true  # Start moving when the animation starts.

func setup_dash_properties():
	level = player.dash_level
	angle = global_position.direction_to(target)
	rotation = 0
	match level:
		1:
			speed = 200
			damage = 10
			knockback_amount = 300
			attack_size = 1.0 * (1 + player.spell_size)
		2:
			speed = 300
			damage = 15
			knockback_amount = 400
			attack_size = 1.0 * (1 + player.spell_size)
		3:
			speed = 400
			damage = 20
			knockback_amount = 500
			attack_size = 1.0 * (1 + player.spell_size)
		4:
			speed = 500
			damage = 25
			knockback_amount = 600
			attack_size = 1.0 * (1 + player.spell_size)

func clean_up_sprite():
	sprite.visible = false  # Make the sprite invisible
	queue_free()  # Enqueue this node for deletion at the end of the current frame

func _process(delta):
	if moving and start_position.distance_to(global_position) < max_distance:
		var movement = (player.global_position - start_position).normalized() * speed * delta
		global_position += movement
		# Calculate the angle from the player to the mouse
		var mouse_position = get_global_mouse_position()
		var direction = (mouse_position - player.global_position).normalized()
		var angle = atan2(direction.y, direction.x) * (180 / PI)
		sprite.flip_h = angle > 90 or angle < -90  # Flip based on angle
		if sprite.flip_h != last_flip_state:
			sprite.position.x *= -1
		last_flip_state = sprite.flip_h  # Update the last flip state

	else:
		moving = false  # Stop moving if maximum distance is reached or animation ends
		clean_up_sprite()  # Call cleanup when movement is finished

	# Optionally, stop moving when the animation finishes
	if animation_player and not animation_player.is_playing():
		moving = false

func _on_AnimationPlayer_animation_finished(anim_name):
	if anim_name == "DASH":
		moving = false  # Ensure the dash stops moving when the animation is over.
		clean_up_sprite()  # Cleanup the sprite when animation finishes

func _on_timer_timeout():
	emit_signal("remove_from_array", self)
	queue_free()
