extends Node

var user
var proj_add = 2
var res_add = 1.2
var effect = false

func _ready():
	user.projectile *= proj_add
	user.resilience *= res_add
	if user.left_arm_type == "gun":
		user.left_arm_cooldown_max /= 1.5
	if user.right_arm_type == "gun":
		user.right_arm_cooldown_max /= 1.5
