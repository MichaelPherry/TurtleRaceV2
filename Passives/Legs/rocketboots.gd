extends Node

var user
var effect = true
var last_state = "grounded"
var active_time = 2

func activate_effect():
	if user.grounded == false:
		last_state = "airborne"
		user.max_speed *= 2
		user.acceleration *= 2
		await Inventory.wait_ticks(user, active_time)
		user.max_speed /= 2
		user.head_cooldown = user.head.cooldown
