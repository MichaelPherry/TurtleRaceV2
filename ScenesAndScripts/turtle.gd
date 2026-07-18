extends CharacterBody2D

#Turtle markers and animations
@onready var visuals = $Visuals
@onready var shadow = $Shadow
@onready var collision = $CollisionShape2D
@onready var shell_anim = $Visuals/Turtle_Body
@onready var rightLeg_anim = $Visuals/rightLeg/AnimatedSprite2D
@onready var leftLeg_anim = $Visuals/leftLeg/AnimatedSprite2D
@onready var rightArm_anim = $Visuals/rightArm/AnimatedSprite2D
@onready var leftArm_anim = $Visuals/leftArm/AnimatedSprite2D
@onready var head_anim = $Visuals/head/AnimatedSprite2D
@onready var face_anim = $Visuals/face/AnimatedSprite2D
@onready var belly = $Visuals/belly
@onready var belly_anim = $Visuals/belly/AnimatedSprite2D
@onready var left_hand_sprite = $Visuals/LeftHand/LeftWeapon
@onready var hat_marker = $Visuals/head/Hat
@onready var left_shoe_marker = $Visuals/leftLeg/AnimatedSprite2D/leftShoe
@onready var right_shoe_marker = $Visuals/rightLeg/AnimatedSprite2D/rightShoe
@onready var left_shoe = $Visuals/leftLeg/AnimatedSprite2D/leftShoe/AnimatedSprite2D
@onready var right_shoe = $Visuals/rightLeg/AnimatedSprite2D/rightShoe/AnimatedSprite2D

#Turtle items and appendages
var left_arm
var left_arm_cooldown_max: float
var left_arm_cooldown = 0
var left_arm_type = null
var right_arm
var right_arm_cooldown_max: float
var right_arm_cooldown = 0
var right_arm_type = null
var head
var head_instance
var head_cooldown_max: float
var head_cooldown = 0
var head_type = null
var shell
var shell_instance
var shell_cooldown_max: float
var shell_cooldown = 0
var shell_type = null
var legs
var legs_cooldown_max: float
var legs_cooldown = 0
var legs_instance
var legs_type = null

var left_ready = false
var right_ready = false
var head_ready = false
var shell_ready = false
var legs_ready = false

#Turtle stats
var acceleration = 5
var resilience = 0.1
var max_speed = 300
var current_speed = 0
var height = 0
var max_height = -500
var projectile = 1
var stun = 0

#Turtle properties
var id
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

func _ready():
	rng = RandomNumberGenerator.new()
	rng.seed = seed
	current_speed = 0
	sim_position = global_position
	$Label.text = str(id)
	$Label.visible = true
	Inventory.rng_calls += 1
	equip()
	add_to_group(id)
	add_to_group("players")
	add_to_group("racing")
	moving_animations()
	
func _process(delta):
	var current_frame = shell_anim.frame
	rightLeg_anim.frame = current_frame
	leftLeg_anim.frame = current_frame
	rightArm_anim.frame = current_frame
	leftArm_anim.frame = current_frame
	head_anim.frame = current_frame
	face_anim.frame = current_frame
	belly_anim.frame = current_frame
	global_position = global_position.lerp(sim_position, 0.25)

func tick(current_tick, tick_rate):
	if Inventory.race_started == false:
		return
			
	if hit == true:
		return
	
	if grounded == false and height == 0:
		start_flying()
	
	if grounded == true and height == max_height:
		stop_flying()
	
	if grounded:
		height = 0
	else:
		height = max_height
	#if curr_tick != current_tick:
		#print(current_tick, " ", id, " ", sim_position.y)
	
	#visuals.position.y = height
	collision.position.y = height
	
	if finished == true:
		velocity.y = 0
		return
	
	current_speed = min(current_speed + acceleration, max_speed)
	if sim_position.y < 50 and direction == -1:
		sim_position.y += 0
	else:
		sim_position.y += current_speed * tick_rate * direction
	curr_tick = current_tick
	tick_rat = tick_rate
	moving_animations()

func equip():
	for body_part in Inventory.appendages:
		if Inventory.server_turtles[id][body_part] != null:
			#instead of using arm below you will eventually have to use the 
			#call function similarly how you do it in the item script
			match body_part:
				"leftArm":
					left_arm = ItemPassivePool.arm(Inventory.server_turtles[id][body_part])
					left_arm_cooldown_max = left_arm.cooldown
					left_arm_cooldown = left_arm_cooldown_max
					left_arm_type = left_arm.type
					#equip_left_item(left_arm)
				"rightArm":
					right_arm = ItemPassivePool.arm(Inventory.server_turtles[id][body_part])
					right_arm_cooldown_max = right_arm.cooldown
					right_arm_cooldown = right_arm_cooldown_max
					right_arm_type = right_arm.type
					#equip_right_item(right_arm)
				"head":
					head = ItemPassivePool.head(Inventory.server_turtles[id][body_part])
					head_cooldown_max = head.cooldown
					head_cooldown = head_cooldown_max
					head_instance = head.passive_scene.instantiate()
					#hat_marker.visible = true
					head_instance.user = self
					hat_marker.add_child(head_instance)
					#equip_hat(head)
				"shell":
					shell = ItemPassivePool.shell(Inventory.server_turtles[id][body_part])
					shell_cooldown_max = shell.cooldown
					shell_cooldown = shell_cooldown_max
					shell_instance = shell.passive_scene.instantiate()
					shell_instance.user = self
					belly.add_child(shell_instance)
				"legs":
					legs = ItemPassivePool.legs(Inventory.server_turtles[id][body_part])
					legs_cooldown_max = legs.cooldown
					legs_cooldown = legs_cooldown_max
					legs_instance = legs.passive_scene.instantiate()
					legs_instance.user = self
					left_shoe_marker.visible = true
					left_shoe.play(legs_instance.name)
					right_shoe_marker.visible = true
					right_shoe.play(legs_instance.name)
					right_shoe_marker.add_child(legs_instance)
					
			var temp = Inventory.server_turtles[id][body_part]

func left_arm_item(user, target, scene):
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
	
func equip_left_item(item):
	left_hand_sprite.texture = item.icon
	left_hand_sprite.flip_h = true

func equip_right_item(item):
	#right_hand_sprite.texture = item.icon
	pass

func equip_hat(hat):
	#hat.texture = hat
	pass
	
func invin_frames():
	invincible = true
	hit = true
	var sped = sim_position.y
	current_speed = current_speed * resilience
	sim_position.y -= current_speed * tick_rat
	var sprite = $Visuals
	sprite.modulate = Color(1, 1, 1, 0.2)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1, 1) 
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1, 0.2)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1, 1) 
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1, 0.2)
	await get_tree().create_timer(0.1).timeout
	sprite.modulate = Color(1, 1, 1, 1) 
	sim_position.y = sped
	moving_animations()
	invincible = false
	hit = false

func moving_animations():
	if current_speed <= 250:
		animation_controller("Walking")
		#animation.play("Walking")
		
	elif current_speed <= 350:
		animation_controller("Jogging")
		#animation.play("Jogging")
	else:
		animation_controller("Running")
		#animation.play("Running")

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
	
func animation_controller(action):
	shell_anim.play(action)
	rightLeg_anim.animation = action
	leftLeg_anim.animation = action
	rightArm_anim.animation = action
	leftArm_anim.animation = action
	head_anim.animation = action
	face_anim.animation = action
	belly_anim.animation = action

	if action == "Running":
		$Visuals/leftArm.position = Vector2(-185, -50)
		$Visuals/rightArm.position = Vector2(80,-140)
		
	else:
		$Visuals/leftArm.position = Vector2(-124, -41)
		$Visuals/rightArm.position = Vector2(49,-90)

func start_flying():
	var tween = create_tween()
	tween.tween_property($Visuals, "position:y", max_height, 1.0)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT_IN)
	
func stop_flying():
	var tween = create_tween()
	tween.tween_property($Visuals, "position:y", 0, 1.0)\
	.set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_OUT_IN)
