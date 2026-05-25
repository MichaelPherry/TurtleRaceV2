extends CharacterBody2D

@onready var shell_anim = $Turtle_Body
@onready var rightLeg_anim = $Turtle_Body/rightLeg/AnimatedSprite2D
@onready var leftLeg_anim = $Turtle_Body/leftLeg/AnimatedSprite2D
@onready var rightArm_anim = $Turtle_Body/rightArm/AnimatedSprite2D
@onready var leftArm_anim = $Turtle_Body/leftArm/AnimatedSprite2D
@onready var head_anim = $Turtle_Body/head/AnimatedSprite2D
@onready var face_anim = $Turtle_Body/face/AnimatedSprite2D
@onready var belly_anim = $Turtle_Body/belly/AnimatedSprite2D
@onready var animation = $AnimationPlayer
@onready var left_hand_sprite = $Turtle_Body/LeftHand/LeftWeapon

var left_arm
var left_arm_cooldown = 0
var right_arm
var right_arm_cooldown = 0
var head
var head_cooldown = 0
var shell
var shell_cooldown = 0
var legs
var legs_cooldown = 0

const SPEED = 100
var speed
#100
var multiplier
var finished = false
var invincible = false
var id
var temp_id
var projectile = 1
var hit = false
var finish_time = "N/A"
var place = "N/A"


func _ready():
	speed = SPEED
	temp_id = Inventory.turtle_items[id]["id"]
	equip()
	add_to_group(id)
	add_to_group("players")
	add_to_group("racing")
	multiplier = randi_range(2,5)
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

func _physics_process(delta):
	if hit == true:
		return
	if finished == true:
		velocity.y = 0
		return
	velocity.y = speed * multiplier
	cooldowns(delta)
	move_and_slide()

func equip():
	for body_part in Inventory.appendages:
		if Inventory.turtle_items[id][body_part] != null:
			#instead of using arm below you will eventually have to use the 
			#call function similarly how you do it in the item script
			match body_part:
				"leftArm":
					left_arm = ItemPassivePool.arm(Inventory.turtle_items[id][body_part])
					left_arm_cooldown = left_arm.cooldown
					equip_left_item(left_arm)
				"rightArm":
					right_arm = ItemPassivePool.arm(Inventory.turtle_items[id][body_part])
					right_arm_cooldown = right_arm.cooldown
					equip_right_item(right_arm)
				"head":
					pass
				"shell":
					pass
				"legs":
					pass	
			var temp = Inventory.turtle_items[id][body_part]

func cooldowns(delta):
	if Inventory.turtle_items[id]["leftArm"] != null:
		if left_arm_cooldown <= 0.0:
			use_item(left_arm, "left_arm_item")
			left_arm_cooldown = left_arm.cooldown
	if Inventory.turtle_items[id]["rightArm"] != null:
		if right_arm_cooldown <= 0.0:
			use_item(right_arm, "right_arm_item")
			right_arm_cooldown = right_arm.cooldown
	if Inventory.turtle_items[id]["head"] != null:
		if head_cooldown <= 0.0:
			use_item(head, "head_item")
			head_cooldown = head.cooldown
	if Inventory.turtle_items[id]["shell"] != null:
		if shell_cooldown <= 0.0:
			use_item(shell, "shell_item")
			shell_cooldown = shell.cooldown
	if Inventory.turtle_items[id]["legs"] != null:
		if legs_cooldown <= 0.0:
			use_item(legs, "legs_item")
			legs_cooldown = legs.cooldown
	left_arm_cooldown -= delta
	right_arm_cooldown -= delta
	head_cooldown -= delta
	shell_cooldown -= delta
	legs_cooldown -= delta

func use_item(body_part, name):
	var players = get_tree().get_nodes_in_group("racing")
	players.shuffle()
	var target = null
	for i in players:
		if i != self:
			target = i
			break
	if target == null:
		return
	body_part.apply(self, target, name)

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
	hat.texture = hat
	
func invin_frames():
	invincible = true
	hit = true
	var sped = velocity.y
	velocity.y = -50
	var sprite = $Turtle_Body
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
		$Turtle_Body/leftArm.position = Vector2(-185, -50)
		$Turtle_Body/rightArm.position = Vector2(80,-140)
		
	else:
		$Turtle_Body/leftArm.position = Vector2(-124, -41)
		$Turtle_Body/rightArm.position = Vector2(49,-90)
