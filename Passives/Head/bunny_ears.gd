extends Node

var user
var accel_mult = 2.5
var max_speed_mult = 2
var effect = true

func _ready():
	user.acceleration *= accel_mult
	user.max_speed *= max_speed_mult
	
func activate_effect():
	user.go_asleep(1, self)
	await Inventory.wait_ticks(user, 1)
	user.head_cooldown = user.head.cooldown
