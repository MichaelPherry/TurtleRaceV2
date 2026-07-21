extends Node

var user
var proj_speed_add = 2
var effect = false

func _ready():
	user.projectile_speed *= proj_speed_add
