extends Node

var mult = 2
var user
var flight_time = 3
var start_tick
var effect = true

func _ready():
	start_tick = user.curr_tick
	
func _process(delta):
	pass

func activate_effect():
	user.grounded = false
	user.multiplier += mult
	user.moving_animations()
	
	#while user.curr_tick - start_tick > flight_time:
		#pass
	await get_tree().create_timer(flight_time).timeout
	user.multiplier -= mult
	user.moving_animations()
	user.head_cooldown = user.head.cooldown
	user.grounded = true
