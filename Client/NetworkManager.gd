extends Node2D

var client: Colyseus.Client
var room: Colyseus.Room
var callbacks: Colyseus.Callbacks
var local_player_name = null
var sessionID
var current_scene = null
var race_scene = preload("res://ScenesAndScripts/main.tscn") 

func _ready():
	client = Colyseus.Client.new("wss://turtleracev2.onrender.com")

func connect_to_matchmaking():
	print("Connecting...")
	room = await client.join_or_create("raceLobby", {"player_name": local_player_name})
	get_tree().current_scene.setup(room)
	room.joined.connect(_on_lobby_joined)

func _on_lobby_joined():
	callbacks = Colyseus.Callbacks.of(room)
	room.message_received.connect(_on_message_received)
	await get_tree().create_timer(1.0).timeout
	
func _on_room_joined(data):
	room.leave()
	await get_tree().process_frame
	var new_room = await client.join_by_id(data.roomId)
	room = new_room
	
	print("Joined room: ", room.get_id())
	print("Session ID: ", room.get_session_id())
	print("Room name: ", room.get_name())
	room.message_received.connect(_on_message_received)
	await get_tree().create_timer(1.0).timeout
	
func send_message(code_text, message):
	room.send_message(code_text, message)

func _on_message_received(type, message):
	if type == "send_turtles":
		Inventory.set_turtles(message)
		get_tree().change_scene_to_packed(race_scene)
	elif type == "seed":
		Inventory.seed = message
		#Inventory.rng.seed = message
	elif type == "id_list":
		Inventory.id_list = message
	elif type == "id_with_name":
		Inventory.id_name_list = message
	elif type == "race_start":
		print(message["startTime"])
		Inventory.start_time = message["startTime"] 
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
			"acceleration": 5.0,
			"resilience": 0.1,
			"max_speed": 300.0,
			"fire_rate": 1.0,
			"projectile_speed": 1.0,
			"luck": 1.0
		},		
		"econ": {
			"gold": 10
		}
	}
