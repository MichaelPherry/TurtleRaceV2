extends CharacterBody2D
var SPEED = 100
var multiplier
var finished = false
var invincible = false
var id
var projectile = 1
var item_holding = load("res://Items/fissile.tres")
var cooldown = 0
var hit = false
@onready var sprite = $AnimatedSprite2D

func _ready():
	add_to_group("players")
	add_to_group("racing")
	cooldown = item_holding.cooldown
	multiplier = randi_range(1,5)
	moving_animations()
	
func _physics_process(delta):
	if hit == true:
		return
	if finished == true:
		velocity.y = 0
		return
	velocity.y = SPEED * multiplier
	if cooldown <= 0.0:
		use_item()
		cooldown = item_holding.cooldown
	move_and_slide()
	cooldown -= delta

func use_item():
	var players = get_tree().get_nodes_in_group("players")
	players.shuffle()
	var target = null
	for i in players:
		if i != self:
			target = i
			break
	if target == null:
		return
	item_holding.apply(self, target)

func moving_animations():
	if SPEED * multiplier <= 150:
		sprite.play("Walking")
	elif SPEED * multiplier <= 250:
		sprite.play("Jogging")
	else:
		sprite.play("Running")

func fissile(user, target, scene):
	var fissile_instance = scene.instantiate()
	fissile_instance.target = target
	fissile_instance.user = user
	fissile_instance.global_position = user.global_position
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
	get_tree().root.add_child(fissile_instance)

func invin_frames():
	invincible = true
	hit = true
	var sped = velocity.y
	velocity.y = -50
	var sprite = $AnimatedSprite2D
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
