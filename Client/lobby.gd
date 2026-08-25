extends Control

@onready var playercount = $Panel/Status
@onready var players = [
	$Panel/PlayerList/Player1,
	$Panel/PlayerList/Player2,
	$Panel/PlayerList/Player3,
	$Panel/PlayerList/Player4
]

var room
var callbacks: Colyseus.Callbacks

func _ready():
	await NetworkManager.lobby.leave()
	NetworkManager.lobby = null
	NetworkManager.connect_to_matchmaking()

func setup(_room):
	room = _room
	print(room)
	connect_room()
	
func connect_room():
	var callbacks = Colyseus.Callbacks.of(room)
	room.message_received.connect(_on_message_received)
	
func update_lobby(data):
	playercount.text = str(data.size()) + "/4 Players"
	
	for label in players:
		label.text = ""
		
	for turtle in data:
		var status = "WAITING"
		if turtle.ready == true:
			status = "READY"
		players[turtle.slot - 1].text = turtle.name + " " + status

func _on_message_received(type, message):
	if type == "lobby_update":
		update_lobby(message)
	elif type == "load_race":
		join_match(message)

func join_match(data):
	print(data)
	await get_tree().create_timer(1.0).timeout
	NetworkManager._on_room_joined(data)
	get_tree().change_scene_to_file("res://ScenesAndScripts/shop.tscn")

func _on_ready_pressed():
	room.send_message("ready", "ready")

func _on_leave_button_down():
	await room.leave()
	get_tree().change_scene_to_file("res://Client/mainmenu.tscn")
