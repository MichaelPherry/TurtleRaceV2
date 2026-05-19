extends Node

var turtle_keys = ["2", "3", "4"]
var appendages = ["leftArm", "rightArm", "head", "shell", "legs"]

var turtle_items = {
	
	"2" : {
		"leftArm" : null,
		"rightArm" : null,
		"head" : null,
		"shell" : null,
		"legs" : null
	},
	
	"3" : {
		"leftArm" : null,
		"rightArm" : null,
		"head" : null,
		"shell" : null,
		"legs" : null
	},
	
	"4" : {
		"leftArm" : null,
		"rightArm" : null,
		"head" : null,
		"shell" : null,
		"legs" : null
	}
}

func reset_turtles():
	for id in turtle_keys:
		for body_part in appendages:
			turtle_items[id][body_part] = null
			
func set_turtles(server_turtles):
	var server_keys = server_turtles.keys()
	var counter = 0
	for id in turtle_keys:
		if server_keys[counter] == NetworkManager.sessionID:
			counter += 1
		for body_part in appendages:
			turtle_items[id][body_part] = server_turtles[server_keys[counter]][body_part]
		counter += 1
