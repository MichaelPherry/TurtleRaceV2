extends PanelContainer
var button_text = "Public Lobby "
var current_clients
var max_clients
var room_id

func _ready():
	$MarginContainer/HBoxContainer/Button.text = button_text + current_clients + " / " + max_clients

func _on_button_button_down():
	if get_tree().current_scene.available_rooms[room_id]["clients"] < get_tree().current_scene.available_rooms[room_id]["maxClients"]:
		NetworkManager.room = await NetworkManager.client.join_by_id(room_id, {"player_name": NetworkManager.local_player_name})
		get_tree().change_scene_to_file("res://Client/Lobby.tscn")
