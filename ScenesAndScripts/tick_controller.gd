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

func _ready():
	spawn_players()

func spawn_players():
	var counter = 0
	for id in Inventory.id_list:
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
	accumulator += delta
	while accumulator >= tick_rate:
		run_tick()
		accumulator -= tick_rate
		
func run_tick():
	current_tick += 1
	for turt in players:
		turt.tick(current_tick, tick_rate)
		
	for projectile in Inventory.projectiles:
		projectile.tick()
	#if current_tick % 5 == 0:
		#print("current tick", current_tick)
	#for projectile in Inventory.projectiles:
		#for player in players:
			#if projectile.sim_position.distance_to(player.sim_position) < hit_radius:
				#projectile.hit(player)
