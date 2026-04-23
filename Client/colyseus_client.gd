extends Node

signal connected
signal joined_room
signal state_changed(state)
signal message_received(type, data)
signal disconnected

var ws := WebSocketPeer.new()

var server_url := "ws://localhost:2567"
var is_connected := false

var room_name := "match"
var room_id := ""
var session_id := ""

func _process(_delta):
	if ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		ws.poll()

		while ws.get_available_packet_count() > 0:
			var packet = ws.get_packet().get_string_from_utf8()
			_parse_server_message(packet)

	elif ws.get_ready_state() == WebSocketPeer.STATE_CLOSED:
		if is_connected:
			is_connected = false
			disconnected.emit()

# ------------------------
# CONNECT
# ------------------------

func connect_to_server():
	var err = ws.connect_to_url(server_url)

	if err == OK:
		print("Connecting to Colyseus...")
	else:
		print("Failed connection")

# ------------------------
# JOIN ROOM
# ------------------------

func join_match():
	var payload = {
		"action":"joinOrCreate",
		"room": room_name
	}

	_send(payload)

# ------------------------
# SEND GAME ACTIONS
# ------------------------

func send_buy_unit(unit_id:String):
	send_message("buy_unit", {
		"unitId": unit_id
	})

func send_move_unit(from_slot:int, to_slot:int):
	send_message("move_unit", {
		"from": from_slot,
		"to": to_slot
	})

func send_message(type:String, data:Dictionary):
	var payload = {
		"action":"message",
		"type": type,
		"data": data
	}

	_send(payload)

# ------------------------
# LOW LEVEL SEND
# ------------------------

func _send(data:Dictionary):
	if ws.get_ready_state() == WebSocketPeer.STATE_OPEN:
		ws.send_text(JSON.stringify(data))

# ------------------------
# RECEIVE
# ------------------------

func _parse_server_message(raw:String):
	var msg = JSON.parse_string(raw)

	if msg == null:
		return

	match msg.action:

		"connected":
			is_connected = true
			session_id = msg.sessionId
			connected.emit()

		"joined":
			room_id = msg.roomId
			joined_room.emit()

		"state":
			state_changed.emit(msg.state)

		"message":
			message_received.emit(msg.type, msg.data)

		"error":
			print("Server Error: ", msg.message)
