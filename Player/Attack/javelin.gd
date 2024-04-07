extends Area2D

var level = 1
var hp = 9999
var speed = 400.0
var damage = 10
var knockback_amount = 600
var paths = 1
var attack_size = 1.0
var attack_speed = 10.0

var target = Vector2.ZERO
var target_array = []

var angle = Vector2.ZERO
var reset_pos = Vector2.ZERO

var enemies_in_contact = []


@onready var player = get_tree().get_first_node_in_group("player")
@onready var prongbok_sprite = $NeutralProngbokCopy # Update to your actual node path
@onready var collision = $CollisionShape2D
@onready var animation_player = $AnimationPlayer # Update to your actual node path
@onready var attackTimer = get_node("%AttackTimer")
@onready var changeDirectionTimer = get_node("%ChangeDirection")
@onready var resetPosTimer = get_node ("%ResetPosTimer")
@onready var snd_attack = $snd_attack

signal remove_from_array(object)

func _ready():
	update_javelin()
	_on_reset_pos_timer_timeout()
	animation_player.play("TOAD")  # Replace with the name of your looping animation

func update_javelin():
	level = player.javelin_level
	match level:
		1:
			hp = 9999
			speed = 600.0
			damage = 10
			knockback_amount = 300
			paths = 1
			attack_size = 1.0 * (1 + player.spell_size)
			attack_speed = 10.0 * (1-player.spell_cooldown)
		2:
			hp = 9999
			speed = 700.0
			damage = 10
			knockback_amount = 400
			paths = 2
			attack_size = 1.0 * (1 + player.spell_size)
			attack_speed = 15.0 * (1-player.spell_cooldown)
		3:
			hp = 9999
			speed = 200.0
			damage = 10
			knockback_amount = 100
			paths = 3
			attack_size = 1.0 * (1 + player.spell_size)
			attack_speed = 5.0 * (1-player.spell_cooldown)
		4:
			hp = 9999
			speed = 200.0
			damage = 15
			knockback_amount = 120
			paths = 3
			attack_size = 1.0 * (1 + player.spell_size)
			attack_speed = 5.0 * (1-player.spell_cooldown)
			
	
	scale = Vector2(1.0,1.0) * attack_size
	attackTimer.wait_time = attack_speed

func _physics_process(delta):
	if target_array.size() > 0:
		var direction = global_position.direction_to(target)
		position += direction * speed * delta
	# Keep the sprite upright; don't rotate
	else:
	# Movement back to reset position or stand still if no target
		var player_direction = global_position.direction_to(player.global_position)
		var distance_dif = global_position - player.global_position
		var return_speed = 20
		if abs(distance_dif.x) > 500 or abs(distance_dif.y) > 500:
			return_speed = 400
		position += player_direction * return_speed * delta
		# Ensure prongbok sprite stays upright
	# Reset rotation if it's been changed elsewhere
	prongbok_sprite.rotation = 0
	prongbok_sprite.flip_h = global_position.x > player.global_position.x

func add_paths():
	snd_attack.play()
	emit_signal("remove_from_array",self)
	target_array.clear()
	var counter = 0
	while counter < paths:
		var new_path = player.get_random_target()
		target_array.append(new_path)
		counter += 1
	enable_attack(true)
	target = target_array[0]
	process_path()

func process_path():
	# Set the movement direction towards the target
	angle = global_position.direction_to(target)
	# Since we're keeping the sprite upright, we might not need to adjust rotation here.
	# However, if you're using the angle for directional logic elsewhere, keep this.
	changeDirectionTimer.start()

func enable_attack(atk = true):
	if atk:
		collision.call_deferred("set","disabled",false)
		animation_player.play("TOAD")
	else:
		collision.call_deferred("set","disabled",true)
		animation_player.play("TOAD")

func _on_attack_timer_timeout():
	add_paths()

func _on_change_direction_timeout():
	if target_array.size() > 0:
		target_array.remove_at(0)
		if target_array.size() > 0:
			target = target_array[0]
			process_path()
			snd_attack.play()
			emit_signal("remove_from_array",self)
		else:
			changeDirectionTimer.stop()
			attackTimer.start()
			enable_attack(false)
	else:
		changeDirectionTimer.stop()
		attackTimer.start()
		enable_attack(false)


func _on_reset_pos_timer_timeout():
	var choose_direction = randi() % 4
	reset_pos = player.global_position
	match choose_direction:
		0:
			reset_pos.x += 50
		1:
			reset_pos.x -= 50
		2:
			reset_pos.y += 50
		3:
			reset_pos.y -= 50
