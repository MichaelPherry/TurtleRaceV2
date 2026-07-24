extends Node

var user
var effect = false
var top_speed_mult = 1

func _ready():
	if user.left_arm == null:
		top_speed_mult += 1
	if user.right_arm == null:
		top_speed_mult += 1
	if user.shell == null:
		top_speed_mult += 1
	if user.legs == null:
		top_speed_mult += 1
	if user.head == null:
		top_speed_mult += 1
		
	user.max_speed *= top_speed_mult
