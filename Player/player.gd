extends CharacterBody2D

# This class represents a character in a game, managing its attributes, 
# abilities, and interactions within the game environment. It includes properties 
# related to movement, health, abilities, and GUI elements.

# Character movement attributes
var movement_speed = 60.0  # Movement speed of the character.
var hp = 200  # Current health of the character.
var maxhp = 200  # Maximum health of the character.
var last_movement = Vector2.UP  # Last movement direction, initialized to 'UP'.
var time = 0  # General purpose timer (could be used for buffs, debuffs, etc.).

# Movement control variables
var destination = position  # The destination point for movement, initialized to the current position.
var stopped = true  # Boolean to control whether the character is moving or stopped.

# Experience and leveling attributes
var experience = 0  # Current experience points.
var experience_level = 1  # Current level of the character.
var collected_experience = 0  # Experience points collected that are not yet applied to the character.

# Attack and abilities preloads
var iceSpear = preload("res://Player/Attack/ice_spear.tscn")  # Preloads the Ice Spear attack scene.
var tornado = preload("res://Player/Attack/tornado.tscn")  # Preloads the Tornado attack scene.
var javelin = preload("res://Player/Attack/javelin.tscn")  # Preloads the Javelin attack scene.
var slash = preload("res://Player/Attack/SLASH.tscn")  # Preloads the Slash attack scene.
var explosion = preload("res://Player/Attack/Explosion.tscn")  # Preloads the Explosion attack scene.
var dash = preload("res://Player/Attack/DASH.tscn")  # Preloads the Dash attack scene.

# Node references for attack timing
@onready var iceSpearTimer = get_node("%IceSpearTimer")  # Timer node for managing Ice Spear cooldown.
@onready var tornadoTimer = get_node("%TornadoTimer")  # Timer node for managing Tornado cooldown.
@onready var tornadoAttackTimer = get_node("%TornadoAttackTimer")  # Timer node for managing delays between Tornado attacks.
@onready var javelinBase = get_node("%JavelinBase")  # Base node for Javelin management.

# Assuming similar timer nodes exist for Slash, Explosion, and Dash in your scene:
@onready var slashTimer = get_node("%SlashTimer")  # Timer node for managing Slash cooldown.
# Optional: Attack timers for managing delays between these attacks (if applicable)
@onready var explosionTimer = get_node("%ExplosionTimer")  # Timer node for managing Explosion cooldown.
@onready var dashTimer = get_node("%DashTimer")  # Timer node for managing Dash cooldown.




# Upgrade and ability enhancement variables
var collected_upgrades = []  # List of collected upgrades.
var upgrade_options = []  # List of available upgrade options.
var armor = 0  # Additional armor points.
var speed = 0  # Additional speed points.
var spell_cooldown = 0  # Reduction in spell cooldown.
var spell_size = 0  # Increase in spell size.
var additional_attacks = 0  # Additional attacks.

# Specific ability properties
var spell_1_on_cd  # Cooldown flag for the first spell, not initialized.
var icespear_ammo = 0  # Ammo count for Ice Spear.
var icespear_baseammo = 0  # Base ammo count for Ice Spear.
var icespear_attackspeed = 1.5  # Attack speed for Ice Spear.
var icespear_level = 0  # Current level of Ice Spear ability.

var slash_on_cd
var slash_level = 1
var slash_attackspeed = 1

var dash_on_cd
var dash_level = 1
var dash_attackspeed = 1

var explosion_on_cd
var explosion_level = 1
var explosion_attackspeed = 1

var tornado_ammo = 0  # Ammo count for Tornado.
var tornado_baseammo = 0  # Base ammo count for Tornado.
var tornado_attackspeed = 3  # Attack speed for Tornado.
var tornado_level = 0  # Current level of Tornado ability.

var javelin_ammo = 0  # Ammo count for Javelin.
var javelin_level = 0  # Current level of Javelin ability.

# Enemy management
var enemy_close = []  # List of close enemies.

# GUI elements and nodes
@onready var sprite = $TerranattackCopy  # Sprite for the Terran attack.
@onready var walk = $AnimationPlayer  # Animation player for walk animations.
@onready var expBar = get_node("%ExperienceBar")  # Experience bar GUI element.
@onready var lblLevel = get_node("%lbl_level")  # Label for displaying the current level.
@onready var levelPanel = get_node("%LevelUp")  # Panel for level up notifications.
@onready var upgradeOptions = get_node("%UpgradeOptions")  # GUI for displaying upgrade options.
@onready var itemOptions = preload("res://Utility/item_option.tscn")  # Preload item options for upgrades.
@onready var sndLevelUp = get_node("%snd_levelup")  # Sound effect for leveling up.
@onready var healthBar = get_node("%HealthBar")  # Health bar GUI element.
@onready var lblTimer = get_node("%lblTimer")  # Timer label GUI element.
@onready var collectedWeapons = get_node("%CollectedWeapons")  # GUI for collected weapons.
@onready var collectedUpgrades = get_node("%CollectedUpgrades")  # GUI for collected upgrades.
@onready var itemContainer = preload("res://Player/GUI/item_container.tscn")  # Preload item container for GUI.

@onready var deathPanel = get_node("%DeathPanel")  # Panel displayed upon death.
@onready var lblResult = get_node("%lbl_Result")  # Label for displaying result upon death.
@onready var sndVictory = get_node("%snd_victory")  # Sound effect for victory.
@onready var sndLose = get_node("%snd_lose")  # Sound effect for losing.

# Signal declaration for player death.
signal playerdeath

func _ready():
	"""
	Prepares the character when the node enters the scene tree. This method initializes
	the character's state, sets up the GUI, and prepares initial game logic settings.
	It's called automatically when the node is added to the active scene.
	"""
	upgrade_character("icespear1")  # Initialize the character with an Ice Spear upgrade.
	upgrade_character("slash1")     # Initialize the character with a basic Slash upgrade.
	upgrade_character("dash1")      # Initialize the character with a basic Dash upgrade.
	upgrade_character("explosion1") # Initialize the character with a basic Explosion upgrade.
	attack()  # Setup and execute initial attack configurations.
	set_expbar(experience, calculate_experiencecap())  # Initialize the experience bar GUI.
	_on_hurt_box_hurt(0, 0, 0)  # Simulate a hurt event to set up initial state.
	
func _input(event):
	if event is InputEventKey and event.pressed:
		match event.keycode:
			KEY_Q:
				activate_slash()
			KEY_W:
				activate_explosion()
			KEY_E:
				activate_dash()
			KEY_R:
				fire_spell_1()

func _physics_process(_delta):
	"""
	The physics process callback handles real-time adjustments to the character's state.
	This method is called every frame and is used to manage character movement and active skill checks.
	"""
	movement()  # Handle character movement based on input and other conditions.

func activate_slash():
	"""
	Handles the activation of the slash skill. This method instantiates the slash effect,
	positions it, and executes the slash attack if the spell is not currently on cooldown.
	"""
	var slashing = slash.instantiate()
	add_child.call_deferred(slashing)
	slashing.global_position = global_position  # Align the slash instance with the player's position
	slashing.execute_slash()  # Trigger the slashing mechanics.
	slash_on_cd = true
	slashTimer.start()


func activate_explosion():
	"""
	Activates the explosion skill. This method creates an instance of the explosion effect,
	sets its position, and triggers the explosion mechanics.
	"""
	var explosioning = explosion.instantiate()
	add_child.call_deferred(explosioning)
	explosioning.position = position  # Set the explosion at the player's location.
	explosioning.create_forcefield_area()  # Initialize the forcefield of the explosion.
	explosion_on_cd = true
	explosionTimer.start()

func activate_dash():
	"""
	Activates the dash skill. This method instantiates the dash effect and executes the dash
	by setting its initial conditions and starting the dash motion.
	"""
	var dashing = dash.instantiate()
	add_child.call_deferred(dashing)
	dashing.position = position  # Position the dash starting point at the player's current location.
	dashing.target = get_global_mouse_position()
	dashing.start_dash()  # Commence the dash movement.
	dash_on_cd = true
	dashTimer.start()


func fire_spell_1():
	"""
	Activates the Ice Spear ability. This function handles the instantiation of the ice spear,
	sets its position, target, and level, and then makes it a child of the current node.
	The function also manages the cooldown of this ability.
	"""
	var arrow = iceSpear.instantiate()
	arrow.position = position  # Set the ice spear's initial position to the character's current position.
	arrow.target = get_global_mouse_position()  # Set the target of the ice spear to the mouse position.
	arrow.level = icespear_level  # Assign the current level of the ice spear to the instantiated object.
	add_child.call_deferred(arrow)  # Add the ice spear to the scene.
	spell_1_on_cd = true  # Set the cooldown flag to true.
	iceSpearTimer.start()  # Start the cooldown timer.

func movement():
	"""
	Handles the character's movement based on player input. This function checks for movement inputs,
	updates the character's position, and controls the animation based on the movement state.
	"""
		# Handle Ice Spear activation
	if Input.is_action_just_pressed("spell_1") and !spell_1_on_cd:
		fire_spell_1()  # Trigger Ice Spear if its specific input is pressed and it is not on cooldown.
		
	# Handle Slash activation
	if Input.is_action_just_pressed("skill_slash") and !slash_on_cd:
		activate_slash()  # Trigger Slash if its specific input is pressed and it is not on cooldown.

	# Handle Explosion activation
	if Input.is_action_just_pressed("skill_explosion") and !explosion_on_cd:
		activate_explosion()  # Trigger Explosion if its specific input is pressed and it is not on cooldown.

	# Handle Dash activation
	if Input.is_action_just_pressed("skill_dash") and !dash_on_cd:
		activate_dash()  # Trigger Dash if its specific input is pressed and it is not on cooldown.
	
	if Input.is_action_just_pressed("right_click"):
		stopped = false  # Set movement to active on right click.
		destination = get_global_mouse_position()  # Update the destination to the mouse position.

	if Input.is_action_just_pressed("stop"):
		stopped = true  # Stop the character's movement if the stop input is pressed.

	var mov = Vector2.ZERO
	if not stopped:
		mov = destination - position  # Calculate the movement vector.
		if mov.length() < 1:
			stopped = true  # Stop the character if close to the destination.

	if mov != Vector2.ZERO:
		walk.play("RUN")  # Play the running animation if moving.
		sprite.flip_h = mov.x < 0  # Flip the sprite based on the direction of movement.
		last_movement = mov
	else:
		walk.stop()  # Stop the walking animation if not moving.

	velocity = mov.normalized() * movement_speed  # Calculate the velocity based on the movement speed.
	move_and_slide()  # Move the character based on the calculated velocity.

func attack():
	"""
	Manages the attack mechanics based on the levels and cooldowns of abilities.
	It checks each ability's level and cooldown before initiating an attack.
	"""
	# Ice Spear attack management
	if icespear_level > 0:
		iceSpearTimer.wait_time = icespear_attackspeed * (1 - spell_cooldown)  # Adjust timer based on attack speed and cooldown reductions.
		if iceSpearTimer.is_stopped():
			iceSpearTimer.start()  # Start the timer if not already running.

	# Tornado attack management
	if tornado_level > 0:
		tornadoTimer.wait_time = tornado_attackspeed * (1 - spell_cooldown)
		if tornadoTimer.is_stopped():
			tornadoTimer.start()

	# Javelin attack management
	if javelin_level > 0:
		spawn_javelin()  # Spawn a javelin if the level is sufficient.

	# Slash attack management
	if slash_level > 0 and not slash_on_cd:  # Check if slash is available and not on cooldown.
		slashTimer.wait_time = slash_attackspeed * (1 - spell_cooldown)
		if slashTimer.is_stopped():
			slashTimer.start()

	# Explosion attack management
	if explosion_level > 0 and not explosion_on_cd:  # Check if explosion is available and not on cooldown.
		explosionTimer.wait_time = explosion_attackspeed * (1 - spell_cooldown)
		if explosionTimer.is_stopped():
			explosionTimer.start()

	# Dash attack management
	if dash_level > 0 and not dash_on_cd:  # Check if dash is available and not on cooldown.
		dashTimer.wait_time = dash_attackspeed * (1 - spell_cooldown)
		if dashTimer.is_stopped():
			dashTimer.start()

func _on_hurt_box_hurt(damage, _angle, _knockback):
	"""
	Handles the event when the character is hurt. It adjusts the character's health based on the damage taken,
	updates the GUI elements to reflect the change, and triggers death if health falls below zero.
	"""
	hp -= clamp(damage - armor, 1.0, 999.0)  # Apply damage to the character's health, adjusted by armor.
	healthBar.max_value = maxhp  # Update the health bar's maximum value.
	healthBar.value = hp  # Update the health bar's current value.
	if hp <= 0:
		death()  # Trigger the death process if health is depleted.

func _on_ice_spear_timer_timeout():
	"""
	Resets the cooldown flag for the Ice Spear spell when its timer expires.
	This allows the Ice Spear ability to be used again.
	"""
	spell_1_on_cd = false

func _on_dash_timer_timeout():
	"""
	Resets the cooldown flag for the Dash ability when its timer expires.
	This allows the Dash ability to be used again.
	"""
	dash_on_cd = false  # Assuming you have a boolean flag for Dash's cooldown.

func _on_slash_timer_timeout():
	"""
	Resets the cooldown flag for the Slash ability when its timer expires.
	This allows the Slash ability to be used again.
	"""
	slash_on_cd = false  # Assuming you have a boolean flag for Slash's cooldown.

func _on_explosion_timer_timeout():
	"""
	Resets the cooldown flag for the Explosion ability when its timer expires.
	This allows the Explosion ability to be used again.
	"""
	explosion_on_cd = false  # Assuming you have a boolean flag for Explosion's cooldown.

func _on_tornado_timer_timeout():
	"""
	This function is called when the tornado ability's main timer times out.
	It replenishes the tornado ammo based on base ammo and additional attacks, and restarts the attack timer.
	"""
	tornado_ammo += tornado_baseammo + additional_attacks  # Replenish tornado ammo.
	tornadoAttackTimer.start()  # Restart the attack timer to allow for another tornado attack.

func _on_tornado_attack_timer_timeout():
	"""
	Handles the timing out of the tornado attack timer. This function creates a new tornado attack
	if there is remaining ammo, configures it, and manages the sequence of tornado attacks.
	"""
	if tornado_ammo > 0:
		var tornado_attack = tornado.instance()
		tornado_attack.position = position  # Set the tornado's position to the player's current position.
		tornado_attack.last_movement = last_movement  # Pass the last movement vector to the tornado for directional purposes.
		tornado_attack.level = tornado_level  # Set the tornado's power level.
		add_child(tornado_attack)  # Add the tornado to the scene.
		tornado_ammo -= 1  # Decrement the ammo count.
		if tornado_ammo > 0:
			tornadoAttackTimer.start()  # If there's still ammo, restart the timer for another attack.
		else:
			tornadoAttackTimer.stop()  # Stop the timer if no ammo remains.

func spawn_javelin():
	"""
	Spawns javelins based on the current ammo and additional attacks.
	This function manages the javelin spawning and ensures the correct number of javelins are active based on the ammo count.
	"""
	var get_javelin_total = javelinBase.get_child_count()  # Get the current number of javelins in play.
	var calc_spawns = (javelin_ammo + additional_attacks) - get_javelin_total  # Calculate the number of new javelins to spawn.
	while calc_spawns > 0:
		var javelin_spawn = javelin.instantiate()
		javelin_spawn.global_position = global_position  # Position the new javelin at the player's location.
		javelinBase.add_child(javelin_spawn)  # Add the new javelin to the javelin base node.
		calc_spawns -= 1
	# Upgrade each javelin if possible.
	var get_javelins = javelinBase.get_children()
	for i in get_javelins:
		if i.has_method("update_javelin"):
			i.update_javelin()  # Update the javelin's properties if applicable.

func get_random_target():
	"""
	Retrieves a random target from the list of close enemies.
	This function provides a utility for selecting a random enemy target within proximity.
	"""
	if enemy_close.size() > 0:
		return enemy_close.pick_random().global_position  # Return a random enemy's position if available.
	else:
		return Vector2.UP  # Return a default position if no enemies are close.

func _on_enemy_detection_area_body_entered(body):
	"""
	Adds an enemy to the list of close enemies when they enter the detection area.
	This function helps in tracking enemies that are within proximity for targeting or AI decisions.
	"""
	if not enemy_close.has(body):
		enemy_close.append(body)

func _on_enemy_detection_area_body_exited(body):
	"""
	Removes an enemy from the list of close enemies when they exit the detection area.
	This ensures the list of close enemies is accurate and up to date.
	"""
	if enemy_close.has(body):
		enemy_close.erase(body)

func _on_grab_area_area_entered(area):
	"""
	Assigns the player as the target when a lootable item enters the grab area.
	This mechanism is used for items that can be collected or interacted with by the player.
	"""
	if area.is_in_group("loot"):
		area.target = self

func _on_collect_area_area_entered(area):
	"""
	Handles the collection of experience from a loot item when it enters the collect area.
	This function is triggered when collectible items designated as 'loot' enter the relevant area around the player.
	"""
	if area.is_in_group("loot"):
		var gem_exp = area.collect()  # Invoke the collect method which should return the experience value.
		calculate_experience(gem_exp)  # Add the collected experience to the player's total.

func calculate_experience(gem_exp):
	"""
	Calculates the player's total experience after collecting experience points (gem_exp).
	Checks if the accumulated experience is enough for a level-up and processes the level-up accordingly.
	"""
	var exp_required = calculate_experiencecap()  # Determine the experience needed for the next level.
	collected_experience += gem_exp  # Add the newly collected experience to the accumulated pool.
	if experience + collected_experience >= exp_required:  # Check if the total experience reaches the cap.
		collected_experience -= exp_required - experience  # Adjust the leftover experience after leveling up.
		experience_level += 1  # Increment the player's level.
		experience = 0  # Reset current experience.
		exp_required = calculate_experiencecap()  # Recalculate the experience cap after leveling up.
		levelup()  # Trigger the leveling up process.
	else:
		experience += collected_experience  # Update current experience if not enough for a level-up.
		collected_experience = 0  # Reset collected experience after updating.
	
	set_expbar(experience, exp_required)  # Update the GUI experience bar with new values.

func calculate_experiencecap():
	"""
	Calculates the experience cap based on the player's current level. Different ranges of levels have different formulas for experience requirements.
	"""
	var exp_cap = experience_level  # Base experience cap is initially set to the current level.
	if experience_level < 20:
		exp_cap = experience_level * 5  # For levels below 20, the cap increases linearly.
	elif experience_level < 40:
		exp_cap = 95 * (experience_level - 19) * 8  # For levels between 20 and 40, the cap scales with a different multiplier.
	else:
		exp_cap = 255 + (experience_level - 39) * 12  # For levels above 40, a different formula is used.
		
	return exp_cap  # Return the calculated experience cap.

func set_expbar(set_value = 1, set_max_value = 100):
	"""
	Sets the values of the experience bar in the GUI to reflect the player's current and maximum experience.
	"""
	expBar.value = set_value  # Set the current value of the experience bar.
	expBar.max_value = set_max_value  # Set the maximum value of the experience bar.

func levelup():
	"""
	Handles the player's leveling up process. This function plays a sound, updates the level display,
	animates the level panel, and provides new upgrade options to the player.
	"""
	sndLevelUp.play()
	lblLevel.text = str("Level: ",experience_level)
	var tween = levelPanel.create_tween()
	tween.tween_property(levelPanel,"position",Vector2(220,50),0.2).set_trans(Tween.TRANS_QUINT).set_ease(Tween.EASE_IN)
	tween.play()
	levelPanel.visible = true
	var options = 0
	var optionsmax = 3
	while options < optionsmax:
		var option_choice = itemOptions.instantiate()
		option_choice.item = get_random_item()
		upgradeOptions.add_child(option_choice)
		options += 1
	get_tree().paused = true
	
func upgrade_character(upgrade):
	match upgrade:
		"dash1":
			dash_level = 1
			# Add specific changes for dash1 here
		"dash2":
			dash_level = 2
			# Add specific changes for dash2 here
		"dash3":
			dash_level = 3
			# Add specific changes for dash3 here
		"dash4":
			dash_level = 4
			# Add specific changes for dash4 here
		"slash1":
			slash_level = 1
			# Add specific changes for slash1 here
		"slash2":
			slash_level = 2
			# Add specific changes for slash2 here
		"slash3":
			slash_level = 3
			# Add specific changes for slash3 here
		"slash4":
			slash_level = 4
			# Add specific changes for slash4 here
		"explosion1":
			explosion_level = 1
			# Add specific changes for explosion1 here
		"explosion2":
			explosion_level = 2
			# Add specific changes for explosion2 here
		"explosion3":
			explosion_level = 3
			# Add specific changes for explosion3 here
		"explosion4":
			explosion_level = 4
			# Add specific changes for explosion4 here
		"icespear1":
			icespear_level = 1
			icespear_baseammo += 1
		"icespear2":
			icespear_level = 2
			icespear_baseammo += 1
		"icespear3":
			icespear_level = 3
		"icespear4":
			icespear_level = 4
			icespear_baseammo += 2
		"tornado1":
			tornado_level = 1
			tornado_baseammo += 1
		"tornado2":
			tornado_level = 2
			tornado_baseammo += 1
		"tornado3":
			tornado_level = 3
			tornado_attackspeed -= 0.5
		"tornado4":
			tornado_level = 4
			tornado_baseammo += 1
		"javelin1":
			javelin_level = 1
			javelin_ammo = 1
		"javelin2":
			javelin_level = 2
		"javelin3":
			javelin_level = 3
		"javelin4":
			javelin_level = 4
		"armor1","armor2","armor3","armor4":
			armor += 1
		"speed1","speed2","speed3","speed4":
			movement_speed += 20.0
		"tome1","tome2","tome3","tome4":
			spell_size += 0.2
		"scroll1","scroll2","scroll3","scroll4":
			spell_cooldown += 0.1
		"ring1","ring2":
			additional_attacks += 1
		"food":
			hp += 20
			hp = clamp(hp,0,maxhp)
	adjust_gui_collection(upgrade)
	attack()
	var option_children = upgradeOptions.get_children()
	for i in option_children:
		i.queue_free()
	upgrade_options.clear()
	collected_upgrades.append(upgrade)
	levelPanel.visible = false
	levelPanel.position = Vector2(800,50)
	get_tree().paused = false
	calculate_experience(0)
	
func get_random_item():
	"""
	Selects a random item from the Upgrade database that hasn't been collected yet and doesn't have any unmet prerequisites.
	This function avoids selecting items that are marked as 'food' or are already displayed as upgrade options.
	"""
	var dblist = []  # List to hold eligible upgrades for random selection.
	for i in UpgradeDb.UPGRADES:
		if i in collected_upgrades or i in upgrade_options or UpgradeDb.UPGRADES[i]["type"] == "item":
			continue  # Skip already collected upgrades, current options, and items classified as food.
		var prerequisites_met = true  # Flag to check if all prerequisites are met.
		for prerequisite in UpgradeDb.UPGRADES[i].get("prerequisite", []):
			if prerequisite not in collected_upgrades:
				prerequisites_met = false
				break
		if prerequisites_met:
			dblist.append(i)
	if dblist.size() > 0:
		var randomitem = dblist.pick_random()
		upgrade_options.append(randomitem)
		return randomitem
	else:
		return null

func change_time(argtime = 0):
	"""
	Updates the game timer and adjusts the displayed time on the GUI.
	"""
	time = argtime  # Set the new time.
	var get_m = int(time / 60.0)  # Calculate minutes from seconds.
	var get_s = time % 60  # Remaining seconds after dividing by 60.
	if get_m < 10:
		get_m = str(0, get_m)  # Format minutes for display.
	if get_s < 10:
		get_s = str(0, get_s)  # Format seconds for display.
	lblTimer.text = str(get_m, ":", get_s)  # Update the timer label.

func adjust_gui_collection(upgrade):
	"""
	Updates the GUI to reflect newly collected upgrades. Displays the new items
	in the respective collection GUI, based on their type.
	"""
	var upgrade_displayname = UpgradeDb.UPGRADES[upgrade]["displayname"]
	var upgrade_type = UpgradeDb.UPGRADES[upgrade]["type"]
	if upgrade_type != "item":  # Check if the upgrade is not a consumable item.
		var new_item = itemContainer.instantiate()  # Create a new GUI element for the upgrade.
		new_item.upgrade = upgrade  # Assign the upgrade data to the GUI element.
		
		# Set a display name or tooltip to the new GUI element
		if new_item.has_method("set_text"):
			new_item.set_text(upgrade_displayname)
		elif new_item.has_node("Label"):  # Assuming there is a Label node in the itemContainer scene
			new_item.get_node("Label").text = upgrade_displayname

		match upgrade_type:
			"weapon":
				collectedWeapons.add_child(new_item)
			"upgrade":
				collectedUpgrades.add_child(new_item)

func death():
	"""
	Handles the player's death, updating the GUI and state accordingly. Also checks if the player has won based on certain conditions.
	"""
	deathPanel.visible = true
	emit_signal("playerdeath")  # Emit a signal indicating the player's death.
	get_tree().paused = true  # Pause the game to handle death.
	
	# Create a tween to animate the death panel.
	var tween = Tween.new()
	add_child(tween)  # Add the Tween node to the scene tree to make it active.
	tween.interpolate_property(deathPanel, "position", deathPanel.position, Vector2(220, 50), 3.0, Tween.TRANS_QUINT, Tween.EASE_OUT)
	tween.start()  # Start the tween animation.

	# Check if the game condition for a win is met.
	if time >= 300:
		lblResult.text = "You Win"
		sndVictory.play()
	else:
		lblResult.text = "You Lose"
		sndLose.play()

func _on_btn_menu_click_end():
	"""
	Handles the end game scenario, cleaning up and redirecting to the main menu.
	"""
	get_tree().paused = false  # Unpause the game.
	get_tree().change_scene_to_file("res://TitleScreen/menu.tscn")  # Change scene to the main menu.
