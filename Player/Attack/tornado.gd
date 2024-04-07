extends Area2D

var level = 1
var hp = 9999
var speed = 200.0
var damage = 10
var attack_size = 2.0
var knockback_amount = 200

var last_movement = Vector2.ZERO
var angle = Vector2.ZERO
var angle_less = Vector2.ZERO
var angle_more = Vector2.ZERO

signal remove_from_array(object)

@onready var player = get_tree().get_first_node_in_group("player")
@onready var sprite = $FireballCopy # Assuming you have a Sprite node as a child
@onready var animation_player = $AnimationPlayer  # Assuming you have an AnimationPlayer node as a child

func _ready():


	match level:
		1:
			hp = 9999
			speed = 200.0
			damage = 10
			knockback_amount = 200
			attack_size = 2.0 * (1 + player.spell_size)
		2:
			hp = 9999
			speed = 250.0
			damage = 15
			knockback_amount = 250
			attack_size = 2.0 * (1 + player.spell_size)
		3:
			hp = 9999
			speed = 300.0
			damage = 20
			knockback_amount = 300
			attack_size = 2.5 * (1 + player.spell_size)
		4:
			hp = 9999
			speed = 350.0
			damage = 25
			knockback_amount = 350
			attack_size = 2.5 * (1 + player.spell_size)

			
	var move_to_less = Vector2.ZERO
	var move_to_more = Vector2.ZERO
	match last_movement:
		Vector2.UP, Vector2.DOWN:
			move_to_less = global_position + Vector2(randf_range(-1,-0.25), last_movement.y)*500
			move_to_more = global_position + Vector2(randf_range(0.25,1), last_movement.y)*500
		Vector2.RIGHT, Vector2.LEFT:
			move_to_less = global_position + Vector2(last_movement.x, randf_range(-1,-0.25))*500
			move_to_more = global_position + Vector2(last_movement.x, randf_range(0.25,1))*500
		Vector2(1,1), Vector2(-1,-1), Vector2(1,-1), Vector2(-1,1):
			move_to_less = global_position + Vector2(last_movement.x, last_movement.y * randf_range(0,0.75))*500
			move_to_more = global_position + Vector2(last_movement.x * randf_range(0,0.75), last_movement.y)*500
	
	angle_less = global_position.direction_to(move_to_less)
	angle_more = global_position.direction_to(move_to_more)
	
	var initital_tween = create_tween().set_parallel(true)
	initital_tween.tween_property(self,"scale",Vector2(1,1)*attack_size,3).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	var final_speed = speed
	speed = speed/5.0
	initital_tween.tween_property(self,"speed",final_speed,6).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_OUT)
	initital_tween.play()
	
	var tween = create_tween()
	var set_angle = randi_range(0,1)
	if set_angle == 1:
		angle = angle_less
		tween.tween_property(self,"angle", angle_more,2)
		tween.tween_property(self,"angle", angle_less,2)
		tween.tween_property(self,"angle", angle_more,2)
		tween.tween_property(self,"angle", angle_less,2)
		tween.tween_property(self,"angle", angle_more,2)
		tween.tween_property(self,"angle", angle_less,2)
	else:
		angle = angle_more
		tween.tween_property(self,"angle", angle_less,2)
		tween.tween_property(self,"angle", angle_more,2)
		tween.tween_property(self,"angle", angle_less,2)
		tween.tween_property(self,"angle", angle_more,2)
		tween.tween_property(self,"angle", angle_less,2)
		tween.tween_property(self,"angle", angle_more,2)
	tween.play()
	

	# Play the initial animation
	animation_player.play("FIREBALL")  # Replace with your act

func _physics_process(delta):
	position += angle*speed*delta
	sprite.flip_h = angle.x > 0


func _on_timer_timeout():
	emit_signal("remove_from_array",self)
	queue_free()
