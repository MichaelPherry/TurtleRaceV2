extends Node

var user
var resilience_mult = 2
var max_speed_mult = 0.75
var effect = false

func _ready():
	user.resilience *= resilience_mult
	user.max_speed *= max_speed_mult
