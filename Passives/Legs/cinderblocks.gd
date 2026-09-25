extends Node

var user
var resilience_add = 10
var resilience_mult = 1.5
var effect = false

func _ready():
	user.resilience += resilience_add
	user.resilience *= resilience_mult
