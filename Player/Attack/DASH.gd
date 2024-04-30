extends Area2D

# This script handles the dashing mechanics of a player or an entity, including movement and effects.
var level = 1
var dash_speed = 700  # The speed at which the dash occurs.
var dash_distance = 500  # The total distance covered by the dash.
var base_damage = 20  # Base damage inflicted by the dash.
var base_knockback_amount = 400  # Base force of knockback applied by the dash.
var dash_duration = 1.5  # The duration in seconds the dash lasts.
var attack_size = 1.0

# Modifiers from player's stats or buffs
var damage_modifier = 1.0
var knockback_modifier = 1.0

@onready var player = get_tree().get_first_node_in_group("player")
@onready var animation_player = get_node("AnimationPlayer")
@onready var cleanup_timer = Timer.new()  # Create a new Timer node for cleanup.

signal remove_from_array(object)

func _ready():
	setup_dash_properties()
	start_dash()
	add_child(cleanup_timer)
	cleanup_timer.wait_time = dash_duration
	cleanup_timer.one_shot = true
	cleanup_timer.connect("timeout", Callable(self, "_on_timer_timeout"))
	cleanup_timer.start()

func setup_dash_properties():
	var damage = base_damage * damage_modifier
	var knockback_amount = base_knockback_amount * knockback_modifier
	match level:
		1:
			dash_speed = 700
			dash_distance = 500
		2:
			dash_speed = 750
			dash_distance = 550
			damage *= 1.1
			knockback_amount *= 1.1
		3:
			dash_speed = 800
			dash_distance = 600
			damage *= 1.2
			knockback_amount *= 1.2
		4:
			dash_speed = 850
			dash_distance = 650
			damage *= 1.3
			knockback_amount *= 1.3

func start_dash():
	if animation_player:
		animation_player.play("DASH")

func _on_timer_timeout():
	apply_effects_at_end_position()

func apply_effects_at_end_position():
	global_position += transform.x * dash_distance
	check_collisions()
	emit_signal("remove_from_array", self)
	queue_free()

func check_collisions():
	var area = $CollisionShape2D as Area2D
	if area:
		for body in area.get_overlapping_bodies():
			if body.is_in_group("enemies"):
				var direction = (body.global_position - global_position).normalized()
				body.call("_on_hurt_box_hurt", calculate_damage(), direction, calculate_knockback())

func calculate_damage():
	return base_damage * damage_modifier * (1 + player.spell_size)

func calculate_knockback():
	return base_knockback_amount * knockback_modifier * (1 + player.spell_size)

func _process(delta):
	if player:
		global_position = player.global_position
