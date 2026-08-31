extends Node

var user
var effect = false
var active = false
var mult = 3

func _ready():
	active = true
	if user.left_arm != null:
		active = false
	if user.right_arm != null:
		active = false
	if user.legs != null:
		active = false
	if user.head != null:
		active = false
		
	user.max_speed *= mult
	user.acceleration *= mult
