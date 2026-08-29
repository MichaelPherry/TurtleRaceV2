extends Control

@onready var name_input = $LineEdit
@onready var name_submit = $NameSubmit
@onready var vbox1 = $ColorRect/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer
@onready var vbox2 = $ColorRect/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2
var race_lobby_button = preload("res://Client/gui_match.tscn") 
var available_rooms = {}
var left_vbox = true

func _ready():
	if NetworkManager.local_player_name == null:
		$ColorRect.visible = false
		Inventory.mode = "multiplayer"
		NetworkManager.client = Colyseus.Client.new("ws://localhost:2567")
		#NetworkManager.client = Colyseus.Client.new("wss://turtleracev2.onrender.com")
		name_submit.disabled = true
	else:
		available_rooms.clear()
		NetworkManager.connect_to_lobby()
		name_input.visible = false
		name_submit.visible = false
	$Panel.visible = false
	update_room_list()

func update_room_list():
	left_vbox = true
	for child in vbox1.get_children():
		child.queue_free()
		
	for child in vbox2.get_children():
		child.queue_free()
	
	for room_id in available_rooms:
		var room = available_rooms[room_id]
		var room_button = race_lobby_button.instantiate()
		room_button.current_clients = str(available_rooms[room_id]["clients"])
		room_button.max_clients = str(available_rooms[room_id]["maxClients"])
		room_button.room_id = room_id
		
		if left_vbox:
			vbox1.add_child(room_button)
			left_vbox = false
		else:
			vbox2.add_child(room_button)
			left_vbox = true

func _on_line_edit_text_changed(new_text):
	new_text = new_text.strip_edges()
	if new_text.is_empty() == false:
		NetworkManager.local_player_name = new_text
		name_submit.disabled = false

func _on_name_submit_pressed():
	NetworkManager.connect_to_lobby()
	name_input.visible = false
	name_submit.visible = false
	$ColorRect.visible = true

func _on_create_button_down() -> void:
	$ColorRect.visible = false
	$Panel.visible = true

func _on_lobby_message(type, message):
	print("Message time: ", Time.get_ticks_msec())
	print("TYPE:", type)
	print("MESSAGE:", message)
	
	if NetworkManager.lobby == null:
		return
		
	match type:
		"rooms":
			available_rooms.clear()

			for room in message:
				available_rooms[room["roomId"]] = room
			
			update_room_list()
			
		"+":
			var room_id = message[0]
			var room_data = message[1]

			available_rooms[room_id] = room_data
			
			update_room_list()
			
		"-":
			var room_id = message

			available_rooms.erase(room_id)
			
			update_room_list()


func _on_online_pressed() -> void:
	$ColorRect.visible = true
	$Panel.visible = false
	NetworkManager.room = await NetworkManager.client.create("raceLobby", {"player_name": NetworkManager.local_player_name})
	get_tree().change_scene_to_file("res://Client/Lobby.tscn")


func _on_cpu_pressed() -> void:
	$ColorRect.visible = true
	$Panel.visible = false
	NetworkManager.room = await NetworkManager.client.create("botLobby", {"player_name": NetworkManager.local_player_name})
	get_tree().change_scene_to_file("res://Client/Lobby.tscn")
