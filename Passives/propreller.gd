extends Node

var mult = 1
var user
var flight_time = 3

func _ready():
	pass
func _process(delta):
	pass

func activate_effect():
	user.grounded = false
	user.multiplier += mult
	user.moving_animations()
	print(user.multiplier)
	
	await get_tree().create_timer(flight_time).timeout
	user.multiplier -= mult
	user.moving_animations()
	user.head_cooldown = user.head.cooldown
	user.grounded = true
	print(user.multiplier)
