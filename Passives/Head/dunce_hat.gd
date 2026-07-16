extends Node

var user
var acceleration_add = 2
var max_speed_add = 1.5
var effect = true
var last_dunce = -1
var dunce_list = [-1,1]


func _ready():
	user.acceleration *= acceleration_add
	user.max_speed *= max_speed_add
	
func activate_effect():
	#Randomly picks -1 or 1 which then makes the turtle either go forward or backward
	if last_dunce == -1:
		last_dunce = 1
	else:
		last_dunce = dunce_list[user.rng.randi_range(0, dunce_list.size() - 1)]
	user.direction = last_dunce
