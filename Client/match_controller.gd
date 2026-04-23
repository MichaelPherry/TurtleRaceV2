extends Node

func _ready():
	Net.connected.connect(_on_connected)
	Net.joined_room.connect(_on_joined)
	Net.state_changed.connect(_on_state_changed)

	Net.connect_to_server()

func _on_connected():
	Net.join_match()

func _on_joined():
	print("Joined Match!")

func _on_state_changed(state):
	print(state)
