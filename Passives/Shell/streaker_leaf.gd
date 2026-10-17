extends Node

var user
var effect = false
var active = false
var mult = 2
var id

func _ready():
	id = user.id
	active = true
	if Inventory.server_turtles[id]["items"]["head"] != null:
		active = false
	if Inventory.server_turtles[id]["items"]["rightArm"] != null:
		active = false
	if Inventory.server_turtles[id]["items"]["leftArm"] != null:
		active = false
	if Inventory.server_turtles[id]["items"]["legs"] != null:
		active = false
		
	if active == true:
		user.max_speed *= mult
		user.acceleration *= mult
