extends Node2D

@onready var background = $RaccoonBackground
@onready var inventoryTurt = $InventoryPanel/InventoryTurtle
@onready var hover_button = $InventoryPanel/HoverButton

var shop_item_icons = []
var tres_item1
var tres_item2
var tres_item3
var id
var done_shopping = false
var shop_time = 40
var temp_pool
signal button_selected(button_name)

func _ready():
	Inventory.start = false
	MusicManager.mainmenu.stop()
	MusicManager.fade_in()
	done_shopping = false
	temp_pool = ItemPassivePool.total_pool.duplicate(true)
	$leftArm.visible = false
	$rightArm.visible = false
	$whichArm.visible = false
	
	Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] += 10
	$Gold.text = "Gold: $" + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"])
	background.play("default")
	
	#$Label.text = str(NetworkManager.local_player_name) + "'s shop"
	$InventoryPanel/PlayerName.text = str(NetworkManager.local_player_name)
	
	item_roll()
	
	hover_button.mouse_entered.connect(_on_inventory_turtle_hovered)
	hover_button.mouse_exited.connect(_on_inventory_turtle_unhovered)
	
	
	$InventoryPanel/Acceleration.text = "Acceleration: " + str(Inventory.local_turtle[NetworkManager.sessionID]["base_stats"]["acceleration"])
	$"InventoryPanel/Top Speed".text = "Top Speed: " + str(Inventory.local_turtle[NetworkManager.sessionID]["base_stats"]["max_speed"])
	$InventoryPanel/Resilience.text = "Resilience: " + str(Inventory.local_turtle[NetworkManager.sessionID]["base_stats"]["resilience"])
	$"InventoryPanel/Fire Rate".text = "Fire Rate: " + str(Inventory.local_turtle[NetworkManager.sessionID]["base_stats"]["fire_rate"])
	$"InventoryPanel/Projectile Speed".text = "Projectile Speed: " + str(Inventory.local_turtle[NetworkManager.sessionID]["base_stats"]["projectile_speed"])
	$InventoryPanel/Luck.text = "Luck: " + str(Inventory.local_turtle[NetworkManager.sessionID]["base_stats"]["luck"])
	
func _process(delta):
	if done_shopping:
		$Label.text = "Starting Race!"
		return
	
	shop_time -= delta
	$Label.text = str(ceil(shop_time))
	if shop_time <= 0:
		done_shopping = true
		NetworkManager.send_message("submit_turtle", Inventory.local_turtle[NetworkManager.sessionID])
	

func item_roll():
	#item layout below [appendage, item]
	Inventory.item_1 = ["arm", "machine_gun"] #rand_items()
	Inventory.item_2 = rand_items()
	Inventory.item_3 = rand_items()

	tres_item1 = get_item_path(Inventory.item_1[0], Inventory.item_1[1])
	tres_item2 = get_item_path(Inventory.item_2[0], Inventory.item_2[1])
	tres_item3 = get_item_path(Inventory.item_3[0], Inventory.item_3[1])
	
	$slot1.texture_normal = tres_item1.icon
	$slot2.texture_normal = tres_item2.icon
	$slot3.texture_normal = tres_item3.icon
	
	$slot1/slot1_cost.text = "$" + str(tres_item1.price)
	$slot2/slot2_cost.text = "$" + str(tres_item2.price)
	$slot3/slot3_cost.text = "$" + str(tres_item3.price)
	
	$slot1.mouse_entered.connect(_on_slot_hovered.bind($slot1))
	$slot1.mouse_exited.connect(_on_slot_unhovered.bind($slot1))
	$slot2.mouse_entered.connect(_on_slot_hovered.bind($slot2))
	$slot2.mouse_exited.connect(_on_slot_unhovered.bind($slot2))
	$slot3.mouse_entered.connect(_on_slot_hovered.bind($slot3))
	$slot3.mouse_exited.connect(_on_slot_unhovered.bind($slot3))
	
func _on_button_button_down():
	NetworkManager.send_message("submit_turtle", Inventory.local_turtle[NetworkManager.sessionID])
	done_shopping = true
	
func _slot1():
	if done_shopping:
		return
	if Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] >= tres_item1.price:
		if Inventory.item_1[0] == "arm":
			Inventory.item_1[0] = await which_arm()
		
		Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] -= tres_item1.price
		$Gold.text = "Gold: $" + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"])
		if Inventory.local_turtle[NetworkManager.sessionID]["items"][Inventory.item_1[0]] != null:
			var old_item = get_item_path(Inventory.item_1[0], Inventory.item_1[1])
			if Inventory.item_1[0] == "leftArm" or Inventory.item_1[0] == "rightArm":
				return_to_item_pool("arm", Inventory.item_1[1])
			else:
				return_to_item_pool(Inventory.item_1[0], Inventory.item_1[1])
			Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] += (old_item.price / 2)
			Inventory.local_turtle[NetworkManager.sessionID]["items"][Inventory.item_1[0]] = null
			
		Inventory.local_turtle[NetworkManager.sessionID]["items"][Inventory.item_1[0]] = Inventory.item_1[1]
		inventoryTurt.equip()
		if Inventory.item_1[0] == "leftArm" or Inventory.item_1[0] == "rightArm":
			Inventory.item_1[0] = "arm"
		ItemPassivePool.total_pool[Inventory.item_1[0]].erase(Inventory.item_1[1])
		$slot1.visible = false
	
func _slot2():
	if done_shopping:
		return
	if Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] >= tres_item2.price:
		if Inventory.item_2[0] == "arm":
			Inventory.item_2[0] = await which_arm()
			
		Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] -= tres_item2.price
		$Gold.text = "Gold: $" + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"])
		if Inventory.local_turtle[NetworkManager.sessionID]["items"][Inventory.item_2[0]] != null:
			var old_item = get_item_path(Inventory.item_2[0], Inventory.item_2[1])
			if Inventory.item_2[0] == "leftArm" or Inventory.item_2[0] == "rightArm":
				return_to_item_pool("arm", Inventory.item_2[1])
			else:
				return_to_item_pool(Inventory.item_2[0], Inventory.item_2[1])
			Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] += (old_item.price / 2)
			Inventory.local_turtle[NetworkManager.sessionID]["items"][Inventory.item_2[0]] = null
			
		Inventory.local_turtle[NetworkManager.sessionID]["items"][Inventory.item_2[0]] = Inventory.item_2[1]
		inventoryTurt.equip()
		if Inventory.item_2[0] == "leftArm" or Inventory.item_2[0] == "rightArm":
			Inventory.item_2[0] = "arm"
		ItemPassivePool.total_pool[Inventory.item_2[0]].erase(Inventory.item_2[1])
		$slot2.visible = false

func _slot3(): 
	if done_shopping:
		return
	if Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] >= tres_item3.price:
		if Inventory.item_3[0] == "arm":
			Inventory.item_3[0] = await which_arm()
			

		Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] -= tres_item3.price
		$Gold.text = "Gold: $" + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"])
		if Inventory.local_turtle[NetworkManager.sessionID]["items"][Inventory.item_3[0]] != null:
			var old_item = get_item_path(Inventory.item_3[0], Inventory.item_3[1])
			if Inventory.item_3[0] == "leftArm" or Inventory.item_3[0] == "rightArm":
				return_to_item_pool("arm", Inventory.item_3[1])
			else:
				return_to_item_pool(Inventory.item_3[0], Inventory.item_3[1])
			Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] += (old_item.price / 2)
			Inventory.local_turtle[NetworkManager.sessionID]["items"][Inventory.item_3[0]] = null
			
		Inventory.local_turtle[NetworkManager.sessionID]["items"][Inventory.item_3[0]] = Inventory.item_3[1]
		inventoryTurt.equip()
		if Inventory.item_3[0] == "leftArm" or Inventory.item_3[0] == "rightArm":
			Inventory.item_3[0] = "arm"
		ItemPassivePool.total_pool[Inventory.item_3[0]].erase(Inventory.item_3[1])
		$slot3.visible = false

func rand_items():
	#$while body_part_list.size() == 0:
	var check_again = true
	var body_part = null
	while check_again:
		body_part = ItemPassivePool.appendages.pick_random()
		if temp_pool[body_part].size() == 0:
			check_again = true
		else:
			check_again = false
	
	var item = temp_pool[body_part].pick_random()
	temp_pool[body_part].erase(item)
	
	return [body_part, item]
	
func which_arm():
	$Button.disabled = true
	$slot1.disabled = true
	$slot2.disabled = true
	$slot3.disabled = true
	
	$leftArm.visible = true
	$rightArm.visible = true
	$whichArm.visible = true
	var arm = await button_selected
	return arm
	
func _on_left_arm():
	$Button.disabled = false
	$slot1.disabled = false
	$slot2.disabled = false
	$slot3.disabled = false
	
	$leftArm.visible = false
	$rightArm.visible = false
	$whichArm.visible = false
	button_selected.emit("leftArm")
	
func _on_right_arm():
	$Button.disabled = false
	$slot1.disabled = false
	$slot2.disabled = false
	$slot3.disabled = false
		
	$leftArm.visible = false
	$rightArm.visible = false
	$whichArm.visible = false
	button_selected.emit("rightArm")

func get_item_path(body_part, item_name):
	if body_part == "leftArm" or body_part == "rightArm":
		body_part = "arm"
	var tres_instance = ItemPassivePool.call(body_part, item_name)
	return tres_instance
	
func return_to_item_pool(body_part, item_name):
	ItemPassivePool.total_pool[body_part].append(item_name)

func _on_slot_hovered(button):
	create_tween().tween_property(button, "scale", Vector2(1.1, 1.1), 0.1)
	button.modulate = Color(1.3, 1.3, 1.3)
	var item
	if button == $slot1:
		item = tres_item1
	elif button == $slot2:
		item = tres_item2
	elif button == $slot3:
		item = tres_item3
	$Tooltop.show_item(item)
	$Tooltop.global_position = button.global_position + Vector2(button.size.x + 10, 0)
	
func _on_slot_unhovered(button):
	create_tween().tween_property(button, "scale", Vector2.ONE, 0.1)
	button.modulate = Color.WHITE
	$Tooltop.hide_tooltip()

func _on_inventory_button_pressed() -> void:
	$InventoryPanel.visible = true
	#create_tween().tween_property($InventoryPanel, "position:x", 1100, 0.2)

func _on_hide_inventory_pressed() -> void:
	$InventoryPanel.visible = false

func _on_inventory_turtle_hovered():
	inventoryTurt.hover()
	
func _on_inventory_turtle_unhovered():
	inventoryTurt.unhover()


func _on_roll_pressed() -> void:
	if done_shopping:
		return
	if Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] >= 5:
		Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] -= 5
		temp_pool = ItemPassivePool.total_pool.duplicate(true)
		$Gold.text = "Gold: $" + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"])
		item_roll()
