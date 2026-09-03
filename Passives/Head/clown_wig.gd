extends Node

var user
var effect = true
var empty_slots = []
var appendages = []
var items = []
var equipped = false

func _ready():
	Inventory.end_items.append(self)
	if Inventory.server_turtles[user.id]["items"]["leftArm"] == null:
		empty_slots.append("leftArm")
	if Inventory.server_turtles[user.id]["items"]["rightArm"] == null:
		empty_slots.append("rightArm")
	if Inventory.server_turtles[user.id]["items"]["legs"] == null:
		empty_slots.append("legs")
	if Inventory.server_turtles[user.id]["items"]["shell"] == null:
		empty_slots.append("shell")
		
	if empty_slots.size() == 0:
		return
	elif empty_slots.size() <= 2:
		for body_part in empty_slots:
			appendages.append(body_part)
	else:
		for i in range( empty_slots.size() - 1, 0, -1):
			var rand_number = user.rng.randi_range(0, i)
			var temp = empty_slots[i]
			empty_slots[i] = empty_slots[rand_number]
			empty_slots[rand_number] = temp
		appendages.append(empty_slots[0])
		appendages.append(empty_slots[1])
		
	for limb in appendages:
		var tempLimb = limb
		if limb == "leftArm" or limb == "rightArm":
			tempLimb = "arm"
		var randItem = ItemPassivePool.all_items[tempLimb][user.rng.randi_range(0, ItemPassivePool.all_items[tempLimb].size() - 1)]

		if limb == "leftArm":
			user.left_arm = randItem
			empty_slots.append("leftArm")
		elif limb == "rightArm":
			user.right_arm = randItem
		elif limb == "legs":
			user.legs = randItem
		elif limb == "shell":
			user.shell = randItem
		items.append(randItem)
		Inventory.server_turtles[user.id]["items"][limb] = randItem
		
func activate_effect():
	if equipped == false:
		user.equip()
		equipped = true
		
func end_effect():
	for body_part in appendages:
		Inventory.server_turtles[user.id]["items"][body_part] = null
	Inventory.end_items.erase(self)
