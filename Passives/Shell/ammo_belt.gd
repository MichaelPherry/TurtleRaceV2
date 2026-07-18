extends Node

var user
var effect = false

func _ready():
	if user.left_arm_type == "gun":
		user.left_arm_cooldown_max /= 2
	if user.right_arm_type == "gun":
		user.right_arm_cooldown_max /= 2
