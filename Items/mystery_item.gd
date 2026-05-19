extends Node

var user
var target
@export var possible_items: Array[Item]


func _ready():
	var chosen = possible_items.pick_random()
	#var temp = ItemPassivePool.arm(chosen.name)
	chosen.apply(user, target, name)
