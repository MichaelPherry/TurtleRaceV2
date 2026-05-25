extends Node

var user
var target
var id 
var body_part
@export var possible_items: Array[Item]


func _ready():
	id = user.id
	if Inventory.turtle_items[id]["leftArm"] == "mystery_item" and Inventory.turtle_items[id]["rightArm"] == "mystery_item":
		if user.left_arm_cooldown <= 0:
			body_part = "left_arm_item"
		else:
			body_part = "right_arm_item"
	elif Inventory.turtle_items[id]["leftArm"] == "mystery_item":
		body_part = "left_arm_item"
	elif Inventory.turtle_items[id]["rightArm"] == "mystery_item":
		body_part = "right_arm_item"
	var chosen = possible_items.pick_random()
	chosen.apply(user, target, body_part)
