extends Area2D

var target
var start_pos
var target_pos
var travel_time = 1
var damage = 1
var height = 100
var t = 0
var user
var mult

func _ready():
	start_pos = user.global_position
	target_pos = target.global_position
	
func _process(delta):
	var t =+ delta / travel_time
	var pos = start_pos.lerp(target_pos, t)
	var arc = sin(t * PI) * height
	
	
