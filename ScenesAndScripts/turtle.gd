extends CharacterBody2D

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
@onready var belly_anim = $Visuals/belly/AnimatedSprite2D
@onready var animation = $AnimationPlayer
@onready var left_hand_sprite = $Visuals/LeftHand/LeftWeapon
@onready var hat_marker = $Visuals/Hat

var left_arm
var left_arm_cooldown = 0
var right_arm
var right_arm_cooldown = 0
var head
var head_instance
var head_cooldown = 0
var shell
var shell_cooldown = 0
var legs
var legs_cooldown = 0

var left_ready = false
var right_ready = false
var head_ready = false
var shell_ready = false
var legs_ready = false

const SPEED = 100
var speed
var height = 0
var max_height = -500
var multiplier
var finished = false
var invincible = false
var id
var projectile = 1
var hit = false
var finish_time = "N/A"
var place = "N/A"
var grounded = true
var rng
var seed
var sim_position

var curr_tick
var tick_rat

func _ready():
	rng = RandomNumberGenerator.new()
	rng.seed = seed
	speed = SPEED
	sim_position = global_position
	$Label.text = str(id)
	Inventory.rng_calls += 1
	print(Inventory.rng_calls, " mult")
	multiplier = rng.randi_range(2,5)
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
	
	if hit == true:
		return
	
	if grounded:
		height = 0
	else:
		height = max_height
	
	curr_tick = current_tick
	tick_rat = tick_rate
	
	visuals.position.y = height
	collision.position.y = height
	
	if finished == true:
		velocity.y = 0
		return
	print(current_tick, id, speed, multiplier, sim_position.y)
	sim_position.y += speed * multiplier * tick_rate

func equip():
	for body_part in Inventory.appendages:
		if Inventory.server_turtles[id][body_part] != null:
			#instead of using arm below you will eventually have to use the 
			#call function similarly how you do it in the item script
			match body_part:
				"leftArm":
					left_arm = ItemPassivePool.arm(Inventory.server_turtles[id][body_part])
					left_arm_cooldown = left_arm.cooldown
					equip_left_item(left_arm)
				"rightArm":
					right_arm = ItemPassivePool.arm(Inventory.server_turtles[id][body_part])
					right_arm_cooldown = right_arm.cooldown
					equip_right_item(right_arm)
				"head":
					head = ItemPassivePool.head(Inventory.server_turtles[id][body_part])
					head_cooldown = head.cooldown
					head_instance = head.passive_scene.instantiate()
					head_instance.user = self
					hat_marker.add_child(head_instance)
					equip_hat(head)
				"shell":
					pass
				"legs":
					pass	
			var temp = Inventory.server_turtles[id][body_part]

func left_arm_item(user, target, scene):
	var instance = scene.instantiate()
	instance.target = target
	instance.user = user
	instance.global_position = user.global_position
	speed = 0
	if instance.ground_trap == true:
		instance.final_position = target_final_position(instance.target)
	if user.global_position.x > target.global_position.x:
		#user.sprite.flip_h = true
		await get_tree().create_timer(0.5).timeout
		#user.sprite.flip_h = false
	else:
		await get_tree().create_timer(0.5).timeout
	speed = SPEED
	moving_animations()
	get_tree().root.add_child(instance)
	
func right_arm_item(user, target, scene):
	var instance = scene.instantiate()
	instance.target = target
	instance.user = user
	instance.global_position = user.global_position
	speed = 0
	if instance.ground_trap == true:
		instance.final_position = target_final_position(instance.target)
	if user.global_position.x > target.global_position.x:
		#user.sprite.flip_h = true
		await get_tree().create_timer(0.5).timeout
		#user.sprite.flip_h = false
	else:
		await get_tree().create_timer(0.5).timeout
	speed = SPEED
	moving_animations()
	get_tree().root.add_child(instance)
	
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
	sim_position.y -= 50
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
	if SPEED * multiplier <= 250:
		animation_controller("Walking")
		#animation.play("Walking")
		
	elif SPEED * multiplier <= 350:
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
		final_position = Vector2(target.sim_position.x, rng.randi_range(target.sim_position.y + min, max))
		print(curr_tick, " final pos ", Inventory.rng_calls)
	return final_position
	
func animation_controller(action):
	animation.play(action)
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
