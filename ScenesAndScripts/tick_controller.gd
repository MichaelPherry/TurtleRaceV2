extends Node2D

@onready var turtle_scene = preload("res://ScenesAndScripts/turtle.tscn")

var start_pos = [Vector2(2700,820),Vector2(4050,820),Vector2(5380,820),Vector2(6750,820)]

var tick_rate = 0.05
var accumulator = 0.0
var server_start = 0
var tick = 0
var current_tick = 0
var players = []
var hit_radius = 200
var appendages = ["leftArm", "rightArm", "head", "shell", "legs"]
signal tick_sig

func _ready():
	spawn_players()
	Inventory.projectiles = []

func spawn_players():
	var counter = 0
	for id in Inventory.name_list:
		var player = turtle_scene.instantiate()
		player.id = id
		var temp = id
		
		player.global_position = start_pos[Inventory.server_turtles[id]["slot"] - 1]
		player.seed = Inventory.seed + counter
		add_child(player)
		counter += 1
	players = get_tree().get_nodes_in_group("players")
	players.sort_custom(func(a,b):
		return a.id < b.id
	)
	

func _process(delta):
	if Inventory.race_started == false:
		if Time.get_unix_time_from_system() >= Inventory.start_time:
			Inventory.race_started = true
		else:
			Inventory.start_time /= 1.05 
			return
	accumulator += delta
	while accumulator >= tick_rate:
		run_tick()
		tick_sig.emit()
		accumulator -= tick_rate
		
func run_tick():
	current_tick += 1
	#player movement
	for turt in players:
		turt.tick(current_tick, tick_rate)
		
	#cooldowns
	for turt in players:
		cooldowns(turt)	
		
	#spawn projectiles and activate passives
	for turt in players:
		if turt.left_ready:
			if turt.finished == false:
				use_item(turt, turt.left_arm, "left_arm_item")
				turt.left_ready = false
		if turt.right_ready:
			if turt.finished == false:
				use_item(turt, turt.right_arm, "right_arm_item")
				turt.right_ready = false
		if turt.head_ready:
			if turt.finished == false:
				turt.head_instance.activate_effect()
				turt.head_ready = false
		if turt.shell_ready:
			if turt.finished == false:
				turt.shell_instance.activate_effect()
				turt.shell_ready = false
		if turt.legs_ready:
			if turt.finished == false:
				turt.legs_instance.activate_effect()
				turt.legs_ready = false
	
	#projectile movement
	for projectile in Inventory.projectiles:
		projectile.tick()
	
	#collision
	for projectile in Inventory.projectiles:
		var simx = projectile.target.sim_position.x
		var simy_with_height = projectile.target.sim_position.y + projectile.target.height
		if projectile.sim_position.distance_to(Vector2(simx, simy_with_height)) < hit_radius:
			projectile.hit(projectile.target)

func cooldowns(player):
	if Inventory.server_turtles[player.id]["leftArm"] != null:
		if player.left_arm_cooldown <= 0.0:
			if player.sim_position.y < 7350:
				player.left_ready = true
				player.left_arm_cooldown = player.left_arm_cooldown_max
	if Inventory.server_turtles[player.id]["rightArm"] != null:
		if player.right_arm_cooldown <= 0.0:
			if player.sim_position.y < 7350:
				player.right_ready = true
				player.right_arm_cooldown = player.right_arm_cooldown_max
	if Inventory.server_turtles[player.id]["head"] != null:
		if player.head_cooldown <= 0.0:
			if player.head_instance.effect == true:
				player.head_ready = true
				player.head_cooldown = player.head_cooldown_max
	if Inventory.server_turtles[player.id]["shell"] != null:
		if player.shell_cooldown <= 0.0:
			if player.shell_instance.effect == true:
				player.shell_ready = true
				player.shell_cooldown = player.shell_cooldown_max
	if Inventory.server_turtles[player.id]["legs"] != null:
		if player.legs_cooldown <= 0.0:
			if player.legs_instance.effect == true:
				player.legs_ready = true
				player.legs_cooldwon = player.legs_cooldown_max
	player.left_arm_cooldown -= tick_rate
	player.right_arm_cooldown -= tick_rate
	player.head_cooldown -= tick_rate
	player.shell_cooldown -= tick_rate
	player.legs_cooldown -= tick_rate
	
func use_item(player, body_part, name):
	var players = get_tree().get_nodes_in_group("racing")
	players.sort_custom(func(a,b):
		return a.id < b.id
	)
	rand_shuffle(player, players)
	var target = null
	for i in players:
		if i != player:
			target = i
			break
	if target == null:
		return
	body_part.apply(player, target, name)

func rand_shuffle(player, normal_array):
	for i in range(normal_array.size() - 1, 0, -1):
		Inventory.rng_calls += 1

		var rand_number = player.rng.randi_range(0, i)
		var temp = normal_array[i]
		normal_array[i] = normal_array[rand_number]
		normal_array[rand_number] = temp
	if normal_array.size() <= 1:
		return []
	if normal_array[0] == player:
		normal_array.pop_front()
