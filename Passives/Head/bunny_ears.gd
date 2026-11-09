extends Node

var user
var accel_mult = 2
var effect = true

func _ready():
	user.acceleration *= accel_mult
	
func activate_effect():
	user.head_active = true
	user.go_asleep(1, self)
	await Inventory.wait_ticks(user, 5)
	user.head_cooldown = user.head.cooldown
	user.head_active = false
