extends Node

var user
var acceleration_add = 1.25
var max_speed_add = 1.5
var effect = false
@onready var sprite = $RollerSkateFlipped

func _ready():
	sprite.visible = false
	user.max_speed *= max_speed_add
	user.acceleration *= acceleration_add
