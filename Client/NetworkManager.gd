extends Node

var client: Colyseus.Client
var room: Colyseus.Room
var callbacks: Colyseus.Callbacks
var sessionID

func _ready():
	client = Colyseus.Client.new("ws://localhost:2567")
	connect_to_matchmaking()

func connect_to_matchmaking():
	print("Connecting...")
	room = await client.join_or_create("matchmaking")
	
	if room:
		print("room! ", room)
		room.joined.connect(_on_room_joined)

func _on_room_joined():
	print("Joined room: ", room.get_id())
	print("Session ID: ", room.get_session_id())
	print("Room name: ", room.get_name())
	sessionID = room.get_session_id()
	Inventory.turtle_items[sessionID] = {
		"leftArm" : null,
		"rightArm" : null,
		"head" : null,
		"shell" : null,
		"legs" : null,
		"id" : sessionID
		}

	callbacks = Colyseus.Callbacks.of(room)
	room.message_received.connect(_on_message_received)

	await get_tree().create_timer(1.0).timeout
	
func send_message():
	room.send_message("save_turt", {room.get_session_id() : Inventory.turtle_items[sessionID]})


func _on_message_received(type, message):
	Inventory.reset_turtles()
	print("message received")
	print(message)
	Inventory.set_turtles(message)
