extends Node2D

@onready var background = $RaccoonBackground

func _ready():
	$leftArm.visible = false
	$rightArm.visible = false
	$whichArm.visible = false
	background.play("default")
	$Label.text = str(NetworkManager.local_player_name) + "'s shop"
	await get_tree().create_timer(1.0).timeout
	NetworkManager.send_message("enter_shop", "enter_shop")
	Inventory.item_1 = rand_items()
	Inventory.item_2 = rand_items()
	Inventory.item_3 = rand_items()
	$fissile.text = Inventory.item_1[1]
	$eel.text = Inventory.item_2[1]	
	$mystery.text = Inventory.item_3[1]
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_button_down():
	NetworkManager.send_message("submit_turtle", Inventory.local_turtle[NetworkManager.sessionID])
	
func _on_fissile():
	if Inventory.item_1[0] == "arm":
		Inventory.item_1[0] = which_arm()
		
	Inventory.local_turtle[NetworkManager.sessionID][Inventory.item_1[0]] = Inventory.item_1[1]

func _on_eel():
	if Inventory.item_2[0] == "arm":
		Inventory.item_2[0] = which_arm()
		
	Inventory.local_turtle[NetworkManager.sessionID][Inventory.item_2[0]] = Inventory.item_2[1]

func _on_mystery(): 
	if Inventory.item_3[0] == "arm":
		Inventory.item_3[0] = which_arm()
		
	Inventory.local_turtle[NetworkManager.sessionID][Inventory.item_3[0]] = Inventory.item_3[1]

func rand_items():
	#$while body_part_list.size() == 0:
	var check_again = true
	var body_part = null
	while check_again:
		body_part = ItemPassivePool.appendages.pick_random()
		if ItemPassivePool.total_pool[body_part].size() == 0:
			check_again = true
		else:
			check_again = false
	
	var item = ItemPassivePool.total_pool[body_part].pick_random()
	ItemPassivePool.total_pool[body_part].erase(item)
	
	return [body_part, item]
	
func which_arm():
	$Button.disabled = true
	$fissile.disabled = true
	$eel.disabled = true
	$mystery.disabled = true
	
	$leftArm.visible = true
	$rightArm.visible = true
	$whichArm.visible = true
	
func _on_left_arm():
	$Button.disabled = false
	$fissile.disabled = false
	$eel.disabled = false
	$mystery.disabled = false
	
	$leftArm.visible = false
	$rightArm.visible = false
	$whichArm.visible = false
	var ret = "leftArm"
	return ret
	
func _on_right_arm():
	$Button.disabled = false
	$fissile.disabled = false
	$eel.disabled = false
	$mystery.disabled = false
		
	$leftArm.visible = false
	$rightArm.visible = false
	$whichArm.visible = false
	var ret = "rightArm"
	return ret
