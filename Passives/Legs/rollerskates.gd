extends Node

var user
var max_speed_add = 2.0
var effect = false
@onready var sprite = $RollerSkateFlipped

func _ready():
	sprite.visible = false
	user.max_speed *= max_speed_add
