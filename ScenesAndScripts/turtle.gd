extends CharacterBody2D

#Turtle markers and animations
@onready var visuals = $Visuals
@onready var shadow = $Shadow
@onready var collision = $CollisionShape2D
@onready var shell_anim = $Visuals/Shell
@onready var legs_anim = $Visuals/Legs
@onready var belly_anim = $Visuals/Belly
@onready var head_anim = $Visuals/Head
@onready var face_anim = $Visuals/Face
@onready var leftArm_anim = $Visuals/LeftArm
@onready var rightArm_anim = $Visuals/RightArm
@onready var stamina_bar = $Visuals/PlayerUI/VBoxContainer/StaminaBar
@onready var name_label = $Visuals/PlayerUI/VBoxContainer/NameLabel

#Turtle items and appendages
var base_animation_speed = 0.5
var left_arm = null
var left_arm_instance = null
var left_arm_cooldown_max: float
var left_arm_cooldown = 0
var left_arm_type = null
var right_arm = null
var right_arm_instance = null
var right_arm_cooldown_max: float
var right_arm_cooldown = 0
var right_arm_type = null
var head = null
var head_instance = null
var head_cooldown_max: float
var head_cooldown = 0
var head_type = null
var shell = null
var shell_instance = null
var shell_cooldown_max: float
var shell_cooldown = 0
var shell_type = null
var legs = null
var legs_cooldown_max: float
var legs_cooldown = 0
var legs_instance = null
var legs_type = null

var left_ready = false
var right_ready = false
var head_ready = false
var shell_ready = false
var legs_ready = false

#Turtle stats
var max_stamina = 100
var current_stamina = 100
var acceleration = 200
var resilience = 10
var max_speed = 300
var current_speed = 200
var normal_height = -50
var height = -50
var max_height = -500
var fire_rate = 1
var projectile_speed = 1
var luck = 1
var stun = 0

#Turtle effects
var asleep
var projectile_amt = 1

#Turtle properties
var id
var name_tag
var finished = false
var invincible = false
var hit = false
var finish_time = "N/A"
var place = "N/A"
var grounded = true

#Misc
var rng
var seed
var sim_position
var direction = 1
var curr_tick = -1
var tick_rat

#way to put effects on certain items
var item_types = {"Gun" : []}
#way to put effects on turtle when being hit
var turtle_effects = []

func _ready():
	rng = RandomNumberGenerator.new()
	rng.seed = seed
	update_stamina_bar()
	
	current_speed = 0
	acceleration = Inventory.server_turtles[id]["base_stats"]["acceleration"]
	resilience = Inventory.server_turtles[id]["base_stats"]["resilience"]
	max_speed = Inventory.server_turtles[id]["base_stats"]["max_speed"]
	fire_rate = Inventory.server_turtles[id]["base_stats"]["fire_rate"]
	projectile_speed = Inventory.server_turtles[id]["base_stats"]["projectile_speed"]
	luck = Inventory.server_turtles[id]["base_stats"]["luck"]
	asleep = false
	
	animation_controller()
	name_label.text = str(name_tag)
	name_label.visible = true
	Inventory.rng_calls += 1
	equip()
	sim_position = global_position
	add_to_group(id)
	add_to_group("players")
	add_to_group("racing")

	
func _process(delta):
	shell_anim.speed_scale = lerp(0.8, 2.0, clamp(current_speed / max_speed, 0.0, 1.0))
	var current_frame = shell_anim.frame
	rightArm_anim.frame = current_frame
	leftArm_anim.frame = current_frame
	belly_anim.frame = current_frame
	legs_anim.frame = current_frame
	head_anim.frame = current_frame
	face_anim.frame = current_frame
	global_position = global_position.lerp(sim_position, 0.25)

func tick(current_tick, tick_rate):
	if Inventory.race_started == false or Inventory.start == false:
		return
		
	if hit == true:
		return
	
	if finished == true:
		velocity.y = 0
		if grounded == true and height == max_height:
			stop_flying()
			collision.position.y = normal_height
		return
	
	if grounded == false and height == normal_height:
		start_flying()
	
	if grounded == true and height == max_height:
		stop_flying()
	
	if grounded:
		height = normal_height
	else:
		height = max_height

	#visuals.position.y = height
	collision.position.y = height 
	
	current_speed = min(current_speed + acceleration, max_speed)
	if (sim_position.y < 50 and direction == -1) or asleep:
		sim_position.y += 0
	else:
		sim_position.y += current_speed * tick_rate * direction
	curr_tick = current_tick
	tick_rat = tick_rate
	
	if current_stamina > 0:
		current_stamina += resilience * tick_rat
		print(resilience * tick_rat)
		current_stamina = min(current_stamina, max_stamina)
	
	update_stamina_bar()


func equip():
	for body_part in Inventory.appendages:
		if Inventory.server_turtles[id]["items"][body_part] != null:
			match body_part:
				"head":
					if head_instance == null:
						head = ItemPassivePool.head(Inventory.server_turtles[id]["items"][body_part])
						head_cooldown_max = head.cooldown
						head_cooldown = head_cooldown_max
						head_instance = head.passive_scene.instantiate()
						head_instance.visible = false
						#hat_marker.visible = true
						head_instance.user = self
						head_anim.add_child(head_instance)
						if head_anim.sprite_frames.has_animation(head.name):
							head_anim.play(head.name)

				"shell":
					if shell_instance == null:
						shell = ItemPassivePool.shell(Inventory.server_turtles[id]["items"][body_part])
						shell_cooldown_max = shell.cooldown
						shell_cooldown = shell_cooldown_max
						shell_instance = shell.passive_scene.instantiate()
						shell_instance.user = self
						shell_instance.visible = false
						belly_anim.add_child(shell_instance)
						if belly_anim.sprite_frames.has_animation(shell.name):
							belly_anim.play(shell.name)
							
				"legs":
					if legs_instance == null:
						legs = ItemPassivePool.legs(Inventory.server_turtles[id]["items"][body_part])
						legs_cooldown_max = legs.cooldown
						legs_cooldown = legs_cooldown_max
						legs_instance = legs.passive_scene.instantiate()
						legs_instance.user = self
						legs_instance.visible = false
						legs_anim.add_child(legs_instance)
						if legs_anim.sprite_frames.has_animation(legs.name):
							legs_anim.play(legs.name)
						
				"leftArm":
					if left_arm_instance == null:
						left_arm = ItemPassivePool.arm(Inventory.server_turtles[id]["items"][body_part])
						left_arm_cooldown_max = left_arm.cooldown
						left_arm_cooldown = left_arm_cooldown_max
						left_arm_type = left_arm.type
						if left_arm.stay_in_hand == true:
							left_arm_instance = left_arm.item_scene.instantiate()
							left_arm_instance.user = self
							left_arm_instance.visible = false
							leftArm_anim.add_child(left_arm_instance)
								
						if leftArm_anim.sprite_frames.has_animation(left_arm.name):
							leftArm_anim.play(left_arm.name)
					
				"rightArm":
					if right_arm_instance == null:
						right_arm = ItemPassivePool.arm(Inventory.server_turtles[id]["items"][body_part])
						right_arm_cooldown_max = right_arm.cooldown
						right_arm_cooldown = right_arm_cooldown_max
						right_arm_type = right_arm.type
						if right_arm.stay_in_hand == true:
							right_arm_instance = right_arm.item_scene.instantiate()
							right_arm_instance.user = self
							right_arm_instance.visible = false
							rightArm_anim.add_child(right_arm_instance)
							
						if rightArm_anim.sprite_frames.has_animation(right_arm.name):
							rightArm_anim.play(right_arm.name)

func left_arm_item(user, target, scene):
	if left_arm.stay_in_hand == true:
		left_arm_instance.use_item(target)
	else:
		var instance = scene.instantiate()
		instance.target = target
		instance.user = user
		instance.global_position = user.global_position + Vector2(0, height)
		current_speed = 0
		if instance.ground_trap == true:
			instance.final_position = target_final_position(instance.target)
		#if user.sim_position.x > target.sim_position.x:
			##user.sprite.flip_h = true
			#await get_tree().create_timer(0.5).timeout
			##user.sprite.flip_h = false
		#else:
			#await get_tree().create_timer(0.5).timeout
		current_speed = max_speed
		#moving_animations()
		get_tree().current_scene.add_child(instance)
	
func right_arm_item(user, target, scene):
	if right_arm.stay_in_hand == true:
		right_arm_instance.use_item(target)
	else:
		var instance = scene.instantiate()
		instance.target = target
		instance.user = user
		instance.global_position = user.global_position + Vector2(0, height)
		current_speed = 0
		if instance.ground_trap == true:
			instance.final_position = target_final_position(instance.target)
		#if user.sim_position.x > target.sim_position.x:
			##user.sprite.flip_h = true
			#await get_tree().create_timer(0.5).timeout
			##user.sprite.flip_h = false
		#else:
			#await get_tree().create_timer(0.5).timeout
		current_speed = max_speed
		#moving_animations()
		get_tree().current_scene.add_child(instance)
	
func invin_frames(stamina_damage = 0, projectile_keywords = null):
	invincible = true
	hit = true
	var temp_effects = turtle_effects.duplicate()
	if projectile_keywords != null:
		projectile_keywords.append_array(temp_effects)
	elif temp_effects.size() > 0:
		projectile_keywords = temp_effects
	
	if projectile_keywords != null:
		#var unique_projectile_keywords = Inventory.dupe_remover(projectile_keywords)
		for word in projectile_keywords:
			if word == "Ruthless":
				resilience = resilience * 0.5
			if word == "Divine":
				resilience = resilience * 1.5

	current_stamina -= stamina_damage
	update_stamina_bar()
	var sped = sim_position.y
	#current_speed = min(current_speed, current_speed * resilience)
	sim_position.y -= current_speed * tick_rat
	var sprite = $Visuals
	sprite.modulate = Color(1, 1, 1, 0.2)
	await Inventory.wait_ticks(self, (stamina_damage / resilience) / 10)
	sprite.modulate = Color(1, 1, 1, 1) 
	await Inventory.wait_ticks(self, (stamina_damage / resilience) / 10)
	sprite.modulate = Color(1, 1, 1, 0.2)
	await Inventory.wait_ticks(self, (stamina_damage / resilience) / 10)
	sprite.modulate = Color(1, 1, 1, 1) 
	await Inventory.wait_ticks(self, (stamina_damage / resilience) / 10)
	sprite.modulate = Color(1, 1, 1, 0.2)
	await Inventory.wait_ticks(self, (stamina_damage / resilience) / 10)
	sprite.modulate = Color(1, 1, 1, 1) 
	sim_position.y = sped
	invincible = false
	hit = false

func update_stamina_bar():
	var percent = current_stamina / max_stamina
	stamina_bar.value = current_stamina
	
	var style = stamina_bar.get_theme_stylebox("fill").duplicate()
	
	if abs(percent) >= 0.5:
		style.bg_color = Color.YELLOW.lerp(Color.GREEN, (percent - 0.5) * 2.0)
	else:
		style.bg_color = Color.RED.lerp(Color.YELLOW, percent * 2.0)
	stamina_bar.add_theme_stylebox_override("fill", style)

func animation_controller():
	var action = "default"
	shell_anim.play(action)
	legs_anim.animation = action
	rightArm_anim.animation = action
	leftArm_anim.animation = action
	head_anim.animation = action
	face_anim.animation = action
	belly_anim.animation = action
	
func target_final_position(target):
	var max = 7500
	var min = 1000
	var final_position
	if (target.sim_position.y + min) > max:
		final_position = Vector2(target.sim_position.x, max)
	else:
		Inventory.rng_calls += 1
		var simpx = target.sim_position.x
		var targy = target.sim_position.y + min
		var randy_targ = rng.randi_range(targy, max)
		final_position = Vector2(simpx, randy_targ)
		#print(final_position.y, " final ", curr_tick, " ", rng.state, " targs ", targy, " randy targ ", randy_targ)
	return final_position
	
func start_flying():
	var tween = create_tween()
	tween.tween_property($Visuals, "position:y", max_height, 1.0)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT_IN)
	
func stop_flying():
	var tween = create_tween()
	tween.tween_property($Visuals, "position:y", -250, 1.0)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT_IN)

func go_asleep(how_long, appendage = null):
	asleep = true
	await Inventory.wait_ticks(self, how_long)
	asleep = false
