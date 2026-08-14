extends Node2D
var server_pid = -1
var server_path = ProjectSettings.globalize_path("res://server/server.exe")

func _on_singleplayer_pressed() -> void:
	Inventory.mode = "singleplayer"
	await start_local_server()
	await wait_for_port(10)
	NetworkManager.client = Colyseus.Client.new("ws://localhost:2567")
	get_tree().change_scene_to_file("res://Client/Lobby.tscn")

func _on_multiplayer_pressed() -> void:
	Inventory.mode = "multiplayer"
	NetworkManager.client = Colyseus.Client.new("wss://turtleracev2.onrender.com")
	get_tree().change_scene_to_file("res://Client/Lobby.tscn")

func start_local_server():
	server_pid = OS.create_process(server_path, [], false)
	NetworkManager.local_server_pid = server_pid

func wait_for_port(timeout):
	var start_time = Time.get_ticks_msec()
	while (Time.get_ticks_msec() - start_time) / 1000.0 < timeout:
		var socket = StreamPeerTCP.new()
		var error = socket.connect_to_host("127.0.0.1", 2567)

		if error == OK:
			while socket.get_status() == StreamPeerTCP.STATUS_CONNECTING:
				socket.poll()
				await get_tree().process_frame

			if socket.get_status() == StreamPeerTCP.STATUS_CONNECTED:
				socket.disconnect_from_host()
				print("Server is ready!")
				return

		socket.disconnect_from_host()

		await get_tree().create_timer(0.1).timeout
