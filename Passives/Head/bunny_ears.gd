extends Node

var user
var max_speed_mult = 2.5
var accel_mult = 0.75
var effect = true

func _ready():
	user.max_speed *= max_speed_mult
	
func activate_effect():
	if user.acceleration >= 1:
		user.acceleration *= accel_mult
