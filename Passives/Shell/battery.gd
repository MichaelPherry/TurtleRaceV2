extends Node

var user
var proj_speed_add = 2
var effect = false

func _ready():
	user.projectile *= proj_speed_add
