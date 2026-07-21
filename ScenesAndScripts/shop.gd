extends Node2D

@onready var background = $RaccoonBackground

var shop_item_icons = []
var tres_item1
var tres_item2
var tres_item3
signal button_selected(button_name)

func _ready():
	print(Inventory.local_turtle)
	$leftArm.visible = false
	$rightArm.visible = false
	$whichArm.visible = false
	
	background.play("default")
	
	$Label.text = str(NetworkManager.local_player_name) + "'s shop"
	
	Inventory.item_1 = rand_items()
	Inventory.item_2 = rand_items()
	Inventory.item_3 = rand_items()
	tres_item1 = get_item_path(Inventory.item_1[0], Inventory.item_1[1])
	tres_item2 = get_item_path(Inventory.item_2[0], Inventory.item_2[1])
	tres_item3 = get_item_path(Inventory.item_3[0], Inventory.item_3[1])
	
	$slot1.texture_normal = tres_item1.icon
	$slot2.texture_normal = tres_item2.icon
	$slot3.texture_normal = tres_item3.icon
	
	$slot1.mouse_entered.connect(_on_slot_hovered.bind($slot1))
	$slot1.mouse_exited.connect(_on_slot_unhovered.bind($slot1))
	$slot2.mouse_entered.connect(_on_slot_hovered.bind($slot2))
	$slot2.mouse_exited.connect(_on_slot_unhovered.bind($slot2))
	$slot3.mouse_entered.connect(_on_slot_hovered.bind($slot3))
	$slot3.mouse_exited.connect(_on_slot_unhovered.bind($slot3))
	
	await get_tree().create_timer(1.0).timeout
	NetworkManager.send_message("enter_shop", "enter_shop")
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_button_button_down():
	NetworkManager.send_message("submit_turtle", Inventory.local_turtle[NetworkManager.sessionID])
	
func _slot1():
	if Inventory.item_1[0] == "arm":
		Inventory.item_1[0] = await which_arm()
		
	Inventory.local_turtle[NetworkManager.sessionID][Inventory.item_1[0]] = Inventory.item_1[1]

func _slot2():
	if Inventory.item_2[0] == "arm":
		Inventory.item_2[0] = await which_arm()
		
	Inventory.local_turtle[NetworkManager.sessionID][Inventory.item_2[0]] = Inventory.item_2[1]

func _slot3(): 
	if Inventory.item_3[0] == "arm":
		Inventory.item_3[0] = await which_arm()
		
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
	return ItemPassivePool.call(body_part, item_name)
	
func _on_slot_hovered(button):
	create_tween().tween_property(button, "scale", Vector2(1.1, 1.1), 0.1)
	button.modulate = Color(1.3, 1.3, 1.3)
	
func _on_slot_unhovered(button):
	create_tween().tween_property(button, "scale", Vector2.ONE, 0.1)
	button.modulate = Color.WHITE
