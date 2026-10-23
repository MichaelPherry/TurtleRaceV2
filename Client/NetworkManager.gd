extends Node2D

var client: Colyseus.Client
var room: Colyseus.Room
var callbacks: Colyseus.Callbacks
var local_server_pid = -1
var local_player_name = null
var sessionID
var current_scene = null
var race_scene = preload("res://ScenesAndScripts/main.tscn")
var boss_scene = preload("res://ScenesAndScripts/boss.tscn") 
var lobby

func _ready():
	pass
	
func connect_to_lobby():
	lobby = await client.join_or_create("lobby")

	if lobby == null:
		print("Failed to connect to lobby")
		return
	print("Connected to lobby: ", lobby.get_id())

	#room = await client.create("raceLobby", {"player_name": local_player_name})
	if get_tree().current_scene != null:
		if get_tree().current_scene.scene_file_path == "res://Client/mainmenu.tscn":
			lobby.message_received.connect(get_tree().current_scene._on_lobby_message)
			#print("Lobby connect: ", Time.get_ticks_msec())

func connect_to_matchmaking():
	#room = await client.join_or_create("raceLobby", {"player_name": local_player_name})
	get_tree().current_scene.setup(room)
	room.joined.connect(_on_lobby_joined)

func _on_lobby_joined():
	callbacks = Colyseus.Callbacks.of(room)
	room.message_received.connect(_on_message_received)
	await get_tree().create_timer(1.0).timeout
	
func _on_room_joined(data):
	if room != null:
		await room.leave()
	room = null
	await get_tree().process_frame
	var new_room = await client.join_by_id(data.roomId)
	room = new_room
	
	#print("Joined room: ", room.get_id())
	#print("Session ID: ", room.get_session_id())
	#print("Room name: ", room.get_name())
	room.message_received.connect(_on_message_received)
	await get_tree().create_timer(1.0).timeout
	
func send_message(code_text, message):
	room.send_message(code_text, message)

func _on_message_received(type, message):
	#print("messages ", type, message)
	if type == "send_turtles":
		Inventory.set_turtles(message)
		get_tree().change_scene_to_packed(race_scene)
	elif type == "seed":
		Inventory.seed = message
		#Inventory.rng.seed = message
	elif type == "id_list":
		Inventory.id_list = message
		Inventory.id_instrument_list = []
		var counter = 0
		for id in message:
			Inventory.id_instrument_list.append([id, Inventory.instruments[counter]])
			counter += 1
	elif type == "id_with_name":
		Inventory.id_name_list = message
	elif type == "id_with_stock":
		Inventory.id_stock_list = message
		Inventory.stock1_turt = message[0][0]
		Inventory.stock2_turt = message[1][0]
		Inventory.stock3_turt = message[2][0]
		Inventory.stock4_turt = message[3][0]
	elif type == "round_results":
		Inventory.rounds = message[0]
		Inventory.round_results = message[1]
	elif type == "race_start":
		print(message["startTime"])
		Inventory.start_time = message["startTime"]
	elif type == "send_boss_turtles":
		Inventory.set_turtles(message[0])
		Inventory.set_turtles(message[2])
		Inventory.boss_id = message[2].keys()[0]
		Inventory.boss_player_name = message[1]
		get_tree().change_scene_to_packed(boss_scene)
	elif type == "session_id":
		sessionID = message
		Inventory.local_turtle[sessionID] = {
		"items": {
			"leftArm" : null,
			"rightArm" : null,
			"head" : null,
			"shell" : null,
			"legs" : null,
			"slot" : null
		},		
		"base_stats": {
			"acceleration": 5.5,
			"resilience": 1,
			"max_speed": 500.0,
			"fire_rate": 1.0,
			"projectile_speed": 1.0,
			"luck": 1.2
		},		
		"econ": {
			"gold": 15,
			"stock1": 0,
			"stock2": 0,
			"stock3": 0,
			"stock4": 0
		},
		"results": {
			"first": 0,
			"second": 0,
			"third": 0,
			"fourth": 0
		},
		
		"name": local_player_name
	}

func _exit_tree():
	if local_server_pid != -1:
		OS.kill(local_server_pid)
		print("Local server stopped")
