extends Node2D

@onready var turtle_scene = preload("res://ScenesAndScripts/turtle.tscn")
@onready var rabbit_scene = preload("res://ScenesAndScripts/rabbit.tscn")
@onready var race_timer = get_parent().get_node("CanvasLayer")
@onready var hud = get_parent().get_node("HUD")

var start_pos = [Vector2(1600,820),Vector2(3600,820),Vector2(5600,820),Vector2(7600,820)]
var boss_pos = [Vector2(2870,820), Vector2(6100,820)]

var tick_rate = 0.05
var accumulator = 0.0
var server_start = 0
var tick = 0
var current_tick = 0
var players = []
var hit_radius = 200
var appendages = ["leftArm", "rightArm", "head", "shell", "legs"]
var parent_scene
signal tick_sig

func _ready():
	parent_scene = get_parent().name
	spawn_players()
	Inventory.projectiles = []

func spawn_players():
	if parent_scene == "Main":
		var counter = 0
		for id in Inventory.id_list:
			var player = turtle_scene.instantiate()
			player.id = id
			player.name_tag = Inventory.label_finder(player.id)
			
			player.global_position = start_pos[Inventory.server_turtles[id]["slot"] - 1]
			player.seed = Inventory.seed + counter
			add_child(player)
			counter += 1
			
		players = get_tree().get_nodes_in_group("players")
		players.sort_custom(func(a,b):
			return a.id < b.id
		)
	elif parent_scene == "Boss":
		var player = turtle_scene.instantiate()
		player.name_tag = Inventory.boss_player_name
		player.id = Inventory.sid_finder(player.name_tag)
		player.global_position = boss_pos[0]
		player.seed = Inventory.seed + 0
		add_child(player)
		
		var boss = rabbit_scene.instantiate()
		boss.id = Inventory.boss_id
		boss.name_tag = Inventory.boss_name_tag
		boss.global_position = boss_pos[1]
		boss.seed = Inventory.seed + 1
		add_child(boss)
		
		players = get_tree().get_nodes_in_group("players")

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
	if Inventory.start == false:
		return
	current_tick += 1
	#player movement
	for turt in players:
		turt.tick(current_tick, tick_rate)
		
	#cooldowns
	for turt in players:
		if turt.kaput == false and Inventory.race_complete == false:
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
		projectile.tick(current_tick, tick_rate)
		
	for item in Inventory.end_items:
		if item.user.finished == true:
			item.end_effect()
	
	#collision
	for projectile in Inventory.projectiles:
		var simx = projectile.target.sim_position.x
		var simy_with_height = projectile.target.sim_position.y + projectile.target.height
		if projectile.sim_position.distance_to(Vector2(simx, simy_with_height)) < hit_radius:
			projectile.hit(projectile.target)
		else:
			for turtle in players:
				var turt_simx = turtle.sim_position.x
				var turt_simy = turtle.sim_position.y + turtle.height
				if projectile.sim_position.distance_to(Vector2(turt_simx, turt_simy)) < hit_radius:
					projectile.hit(turtle)

	#Time tick down
	race_timer.tick(tick_rate)

func cooldowns(player):
	if Inventory.server_turtles[player.id]["items"]["leftArm"] != null:
		if player.left_arm_cooldown <= 0.0:
			if player.sim_position.y < 7450:
				player.left_ready = true
				player.left_arm_cooldown = player.left_arm_cooldown_max

	if Inventory.server_turtles[player.id]["items"]["rightArm"] != null:
		if player.right_arm_cooldown <= 0.0:
			if player.sim_position.y < 7450:
				player.right_ready = true
				player.right_arm_cooldown = player.right_arm_cooldown_max

	if Inventory.server_turtles[player.id]["items"]["head"] != null:
		if player.head_cooldown <= 0.0:
			if player.head_instance.effect == true:
				player.head_ready = true
				player.head_cooldown = player.head_cooldown_max

	if Inventory.server_turtles[player.id]["items"]["shell"] != null:
		if player.shell_cooldown <= 0.0:
			if player.shell_instance.effect == true:
				player.shell_ready = true
				player.shell_cooldown = player.shell_cooldown_max

	if Inventory.server_turtles[player.id]["items"]["legs"] != null:
		if player.legs_cooldown <= 0.0:
			if player.legs_instance.effect == true:
				player.legs_ready = true
				player.legs_cooldown = player.legs_cooldown_max

	player.left_arm_cooldown -= tick_rate
	player.right_arm_cooldown -= tick_rate
	player.head_cooldown -= tick_rate
	player.shell_cooldown -= tick_rate
	player.legs_cooldown -= tick_rate
	if player.name_tag == NetworkManager.local_player_name:
		hud.tick(player)
		
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
