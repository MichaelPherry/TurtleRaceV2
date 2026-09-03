extends Node

var user
var effect = true
var last_state = "grounded"

func activate_effect():
	if user.grounded == false and last_state == "grounded":
		last_state = "airborne"
		pass
