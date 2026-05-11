extends Node

var client: Colyseus.Client
var room: Colyseus.Room

func _ready():
	client = Colyseus.Client.new("ws://localhost:2567")

func connect_to_matchmaking():
	print("Connecting...")

	room = await client.join_or_create("matchmaking")

	print("Connected to room!")
