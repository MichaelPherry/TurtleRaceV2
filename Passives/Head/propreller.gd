extends Node

var max_speed_mult = 1.5
var accel_mult = 100
var user
var flight_time = 3
var start_tick
var effect = true

var orig_max_speed

func _ready():
	start_tick = user.curr_tick
	
func _process(delta):
	pass

func activate_effect():
	orig_max_speed = user.max_speed
	user.grounded = false
	user.max_speed *= max_speed_mult
	user.acceleration *= accel_mult

	#while user.curr_tick - start_tick > flight_time:
		#pass
	await Inventory.wait_ticks(user, flight_time)
	user.max_speed = orig_max_speed
	user.head_cooldown = user.head.cooldown
	user.grounded = true
