extends Node

var user
var effect = true
var active_time = 3

func activate_effect():
	user.turtle_effects.append("Divine")
	await Inventory.wait_ticks(user, active_time)
	user.head_cooldown = user.head.cooldown
	user.turtle_effects.erase("Divine")
