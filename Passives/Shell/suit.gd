extends Node

var user
var effect = false

func _ready():
	Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] += 5
