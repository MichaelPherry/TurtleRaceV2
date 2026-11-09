extends Control

@onready var name_input = $LineEdit
@onready var name_submit = $NameSubmit
@onready var play_button = $Play
@onready var exit_button = $Exit
@onready var online = $Online
@onready var offline = $Offline
@onready var back_button = $Back
@onready var cancel = $CancelSearch

var room
var callbacks: Colyseus.Callbacks

func _ready():
	if NetworkManager.local_player_name == null:
		Inventory.mode = "multiplayer"
		NetworkManager.client = Colyseus.Client.new("ws://localhost:2567")
		#NetworkManager.client = Colyseus.Client.new("wss://turtleracev2.onrender.com")
		name_submit.disabled = true
		
	name_input.visible = false
	name_submit.visible = false

func _on_play_pressed() -> void:
	MusicManager.play_effect("button_click")
	play_button.visible = false
	exit_button.visible = false
	if NetworkManager.local_player_name == null:
		name_input.visible = true
		name_submit.visible = true
	else:
		online.visible = true
		offline.visible = true
		back_button.visible = true

func _on_exit_pressed() -> void:
	get_tree().quit()

func _on_line_edit_text_changed(new_text):
	new_text = new_text.strip_edges()
	if new_text.is_empty() == false:
		NetworkManager.local_player_name = new_text
		name_submit.disabled = false

func _on_name_submit_pressed():
	NetworkManager.connect_to_lobby()
	MusicManager.play_effect("button_click")
	name_input.visible = false
	name_submit.visible = false
	online.visible = true
	offline.visible = true
	back_button.visible = true

func _on_online_pressed() -> void:
	MusicManager.play_effect("button_click")
	$SearchTimer.start_search_timer()
	cancel.visible = true
	exit_button.visible = true
	online.visible = false
	offline.visible = false
	back_button.visible = false
	
	NetworkManager.room = await NetworkManager.client.join_or_create("raceLobby", {"player_name": NetworkManager.local_player_name})
	NetworkManager.on_or_offline = "online"
	NetworkManager.lobby = null
	NetworkManager.connect_to_matchmaking()
	
func _on_offline_pressed() -> void:
	MusicManager.play_effect("button_click")
	$SearchTimer.start_search_timer()
	cancel.visible = true
	exit_button.visible = true
	online.visible = false
	offline.visible = false
	back_button.visible = false
	
	NetworkManager.room = await NetworkManager.client.create("botLobby", {"player_name": NetworkManager.local_player_name})
	NetworkManager.on_or_offline = "offline"
	NetworkManager.lobby = null
	NetworkManager.connect_to_matchmaking()

func _on_cancel_search_pressed() -> void:
	MusicManager.play_effect("button_click")
	NetworkManager.on_or_offline = null
	$SearchTimer.stop_search_timer()
	
	if room != null:
		await room.leave()
		room = null
	
	cancel.visible = false
	play_button.visible = true

func _on_back_pressed() -> void:
	MusicManager.play_effect("button_click")
	online.visible = false
	offline.visible = false
	back_button.visible = false
	play_button.visible = true
	exit_button.visible = true


func setup(_room):
	room = _room
	print(room)
	await connect_room()
	#await get_tree().create_timer(3).timeout
	room.send_message("ready", "ready")
	
func connect_room():
	var callbacks = Colyseus.Callbacks.of(room)
	room.message_received.connect(_on_message_received)
	
func _on_message_received(type, message):
	if type == "load_race":
		join_match(message)

func join_match(data):
	print(data)
	await get_tree().create_timer(1.0).timeout
	NetworkManager._on_room_joined(data)
	var temp = get_tree()
	if is_inside_tree():
		$SearchTimer.stop_search_timer()
		get_tree().change_scene_to_file("res://ScenesAndScripts/shop.tscn")
