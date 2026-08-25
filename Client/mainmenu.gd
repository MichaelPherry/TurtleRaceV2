extends Control

@onready var name_input = $LineEdit
@onready var name_submit = $NameSubmit
@onready var vbox1 = $ColorRect/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer
@onready var vbox2 = $ColorRect/PanelContainer/MarginContainer/HBoxContainer/VBoxContainer2
var race_lobby_button = preload("res://Client/gui_match.tscn") 

func _ready():
	if NetworkManager.local_player_name == null:
		$ColorRect.visible = false
		Inventory.mode = "multiplayer"
		#NetworkManager.client = Colyseus.Client.new("ws://localhost:2567")
		NetworkManager.client = Colyseus.Client.new("wss://turtleracev2.onrender.com")
		name_submit.disabled = true
	else:
		name_input.visible = false
		name_submit.visible = false

func update_room_list():
	for child in vbox1.get_children():
		child.queue_free()
		
	for child in vbox2.get_children():
		child.queue_free()
	
	for room_id in NetworkManager.available_rooms:
		var room = NetworkManager.available_rooms[room_id]
		var room_button = race_lobby_button.instantiate()
		room_button.current_clients = str(NetworkManager.available_rooms[room_id]["clients"])
		room_button.max_clients = str(NetworkManager.available_rooms[room_id]["maxClients"])
		room_button.room_id = room_id
		
		
		if vbox2.get_children().size() < vbox1.get_children().size():
			vbox2.add_child(room_button)
		else:
			vbox1.add_child(room_button)
			
		print("VBOX1: ", vbox1.get_children())
		print("VBOX2: ", vbox2.get_children())

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
	NetworkManager.room = await NetworkManager.client.create("raceLobby", {"player_name": NetworkManager.local_player_name})
	#await NetworkManager.lobby.message_received.connect(NetworkManager._on_lobby_message)
	get_tree().change_scene_to_file("res://Client/Lobby.tscn")
