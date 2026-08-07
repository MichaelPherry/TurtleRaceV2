extends Node2D

func _on_singleplayer_pressed() -> void:
	Inventory.mode = "singleplayer"
	NetworkManager.client = Colyseus.Client.new("ws://localhost:2567")
	get_tree().change_scene_to_file("res://Client/Lobby.tscn")

func _on_multiplayer_pressed() -> void:
	Inventory.mode = "multiplayer"
	#NetworkManager.client = Colyseus.Client.new("ws://localhost:2567")
	NetworkManager.client = Colyseus.Client.new("wss://turtleracev2.onrender.com")
	get_tree().change_scene_to_file("res://Client/Lobby.tscn")
