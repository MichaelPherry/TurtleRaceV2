extends Node

#Format grabbed from server
#	"id" : {
#		"leftArm" : null,
#		"rightArm" : null,
#		"head" : null,
#		"shell" : null,
#		"legs" : null,
#		"slot" : integer
#	
#	}
var appendages = ["leftArm", "rightArm", "head", "shell", "legs"]
var rng_calls = 0
var id_list
var seed
var local_turtle = {}
var server_turtles = {}
var start_time
var projectiles = []

func reset_turtles():
	var server_keys = server_turtles.keys()
	for id in server_keys:
		for body_part in appendages:
			server_turtles[id][body_part] = null
		server_turtles[id]["slot"] = null
		
func set_turtles(turtles):
	var server_keys = turtles.keys()
	for id in server_keys:
		for body_part in appendages:	
			server_turtles.get_or_add(id, {})[body_part] = turtles[id]["build"][body_part]
		server_turtles[id]["slot"] = turtles[id]["slot"]
	#print(server_turtles)
