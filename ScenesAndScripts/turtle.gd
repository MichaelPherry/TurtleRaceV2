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

func _ready():
	rng = RandomNumberGenerator.new()
	rng.seed = seed
	speed = SPEED
	$Label.text = str(id)
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

func tick(current_tick, tick_rate):
	if hit == true:
		return
	
	if grounded:
		height = 0
	else:
		height = max_height
	visuals.position.y = height
	collision.position.y = height
	
	if finished == true:
		velocity.y = 0
		return
		
	velocity.y = speed * multiplier
	cooldowns(tick_rate)
	
func _physics_process(delta):
	if hit == true:
		return
	
	if finished == true:
		velocity.y = 0
		return
	move_and_slide()

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

func cooldowns(cooldown_rate):
	if Inventory.server_turtles[id]["leftArm"] != null:
		if left_arm_cooldown <= 0.0:
			use_item(left_arm, "left_arm_item")
			left_arm_cooldown = left_arm.cooldown
	if Inventory.server_turtles[id]["rightArm"] != null:
		if right_arm_cooldown <= 0.0:
			use_item(right_arm, "right_arm_item")
			right_arm_cooldown = right_arm.cooldown
	if Inventory.server_turtles[id]["head"] != null:
		if head_cooldown <= 0.0:
			if is_instance_valid(head_instance):
				head_instance.activate_effect()
				head_cooldown = head.cooldown
	left_arm_cooldown -= cooldown_rate
	right_arm_cooldown -= cooldown_rate
	head_cooldown -= cooldown_rate

func use_item(body_part, name):
	var players = get_tree().get_nodes_in_group("racing")
	rand_shuffle(players)
	var target = null
	for i in players:
		if i != self:
			target = i
			break
	if target == null:
		return
	body_part.apply(self, target, name)
	
func use_passive(body_part, name):
	body_part.apply(self, name)

func left_arm_item(user, target, scene):
	var instance = scene.instantiate()
	instance.target = target
	instance.user = user
	instance.global_position = user.global_position
	speed = 0
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
	var sped = velocity.y
	velocity.y = -50
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
	velocity.y = sped
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

func rand_shuffle(normal_array):
	for i in range(normal_array.size() - 1, 0, -1):
		var rand_number = rng.randi_range(0, i)
		var temp = normal_array[i]
		normal_array[i] = normal_array[rand_number]
		normal_array[rand_number] = temp
	if normal_array[0] == self:
		normal_array.pop_front()

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
