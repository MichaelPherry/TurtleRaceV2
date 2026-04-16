extends CharacterBody2D
var SPEED = 100
#100
var multiplier
var finished = false
var invincible = false
var id
var projectile = 1
var left_arm = load("res://Items/fissile.tres")
#var left_arm = load("res://Items/mystery_item.tres")
var cooldown = 0
var hit = false
var finish_time = 45

@onready var sprite = $Turtle_Body
@onready var animation = $AnimationPlayer
@onready var left_hand_sprite = $Turtle_Body/LeftHand/LeftWeapon

func _ready():
	var temp = left_arm.name
	left_arm = ItemPassivePool.arm(left_arm)
	add_to_group(id)
	add_to_group("players")
	add_to_group("racing")
	cooldown = left_arm.cooldown
	equip_left_item(left_arm)
	multiplier = randi_range(2,5)
	moving_animations()
	
func _physics_process(delta):
	if hit == true:
		return
	if finished == true:
		velocity.y = 0
		sprite.play("Standing")
		animation.play("Standing")
		return
	velocity.y = SPEED * multiplier
	if cooldown <= 0.0:
		use_item()
		cooldown = left_arm.cooldown
	move_and_slide()
	cooldown -= delta

func use_item():
	var players = get_tree().get_nodes_in_group("racing")
	players.shuffle()
	var target = null
	for i in players:
		if i != self:
			target = i
			break
	if target == null:
		return
	left_arm.apply(self, target)

func moving_animations():
	if SPEED * multiplier <= 250:
		sprite.play("Walking")
		animation.play("Walking")
		
	elif SPEED * multiplier <= 350:
		sprite.play("Jogging")
		animation.play("Jogging")
	else:
		sprite.play("Running")
		animation.play("Running")

func left_arm_item(user, target, scene):
	var instance = scene.instantiate()
	instance.target = target
	instance.user = user
	instance.global_position = user.global_position
	var sped = SPEED
	SPEED = 0
	if user.global_position.x > target.global_position.x:
		#user.sprite.flip_h = true
		await get_tree().create_timer(0.5).timeout
		#user.sprite.flip_h = false
	else:
		await get_tree().create_timer(0.5).timeout
	SPEED = sped
	moving_animations()
	get_tree().root.add_child(instance)
	
func fissile(user, target, scene):
	return
	var instance = scene.instantiate()
	instance.target = target
	instance.user = user
	instance.global_position = user.global_position
	var sped = SPEED
	SPEED = 0
	if user.global_position.x > target.global_position.x:
		user.sprite.flip_h = true
		user.sprite.play('Fissile')
		await get_tree().create_timer(0.5).timeout
		user.sprite.flip_h = false
	else:
		user.sprite.play('Fissile')
		await get_tree().create_timer(0.5).timeout
	SPEED = sped
	moving_animations()
	get_tree().root.add_child(instance)

func eel_spit(user, target, scene):
	return
	var instance = scene.instantiate()
	instance.target = target
	instance.user = user
	instance.global_position = user.global_position
	var sped = SPEED
	SPEED = 0
	if user.global_position.x > target.global_position.x:
		#user.sprite.flip_h = true
		#user.sprite.play('Fissile')
		await get_tree().create_timer(0.5).timeout
		#user.sprite.flip_h = false
	else:
		#user.sprite.play('Fissile')
		await get_tree().create_timer(0.5).timeout
	SPEED = sped
	moving_animations()
	get_tree().root.add_child(instance)

func equip_left_item(item):
	left_hand_sprite.texture = item.icon
	left_hand_sprite.flip_h = true

func equip_hat(hat):
	hat.texture = "res://Art/AlexArt/Items/Propeller/Idle ProHat/ProHat Idle0001.png"
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
