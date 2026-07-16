extends Node

var user
var mult_add = 2.5
var mult_minus = 0.3
var effect = true

func _ready():
	user.multiplier *= mult_add
	
func activate_effect():
	if user.multiplier >= 0.75:
		user.multiplier -= mult_minus
