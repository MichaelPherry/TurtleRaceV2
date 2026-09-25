extends Node2D

@onready var background = $RaccoonBackground
@onready var inventoryTurt = $InventoryPanel/InventoryTurtle
@onready var hover_button = $InventoryPanel/HoverButton
@onready var head_image = $InventoryPanel/ItemsVBox/Items/Head
@onready var shell_image = $InventoryPanel/ItemsVBox/Items/Shell
@onready var leftArm_image = $InventoryPanel/ItemsVBox/Items/LeftArm
@onready var rightArm_image = $InventoryPanel/ItemsVBox/Items/RightArm
@onready var legs_image = $InventoryPanel/ItemsVBox/Items/Legs
@onready var racc_slot1 = $RaccoonBackground/slot1
@onready var racc_slot2 = $RaccoonBackground/slot2
@onready var racc_slot3 = $RaccoonBackground/slot3

var head_path
var shell_path
var leftArm_path
var rightArm_path
var legs_path

var shop_item_icons = []
var shop_item1
var shop_item2
var shop_item3
var id
var done_shopping = false
var shop_time = 40
var temp_pool
var roll_counter
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
	
	roll_counter = 1
	Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] += 10
	$Gold.text = "Gold: $" + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"])
	background.play("default")
	
	#$Label.text = str(NetworkManager.local_player_name) + "'s shop"
	$InventoryPanel/PlayerName.text = str(NetworkManager.local_player_name)
	
	item_roll()
	
	hover_button.mouse_entered.connect(_on_inventory_turtle_hovered)
	hover_button.mouse_exited.connect(_on_inventory_turtle_unhovered)
	
	inventory_items()
	inventory_update()

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
	Inventory.item_1 = rand_items()
	Inventory.item_2 = rand_items()
	Inventory.item_3 = rand_items()

	shop_item1 = get_item_path(Inventory.item_1[0], Inventory.item_1[1])
	shop_item2 = get_item_path(Inventory.item_2[0], Inventory.item_2[1])
	shop_item3 = get_item_path(Inventory.item_3[0], Inventory.item_3[1])
	
	racc_slot1.texture_normal = shop_item1.icon
	racc_slot2.texture_normal = shop_item2.icon
	racc_slot3.texture_normal = shop_item3.icon
	
	$RaccoonBackground/slot1/slot1_cost.text = "$" + str(shop_item1.price)
	$RaccoonBackground/slot2/slot2_cost.text = "$" + str(shop_item2.price)
	$RaccoonBackground/slot3/slot3_cost.text = "$" + str(shop_item3.price)
	
	racc_slot1.visible = true
	racc_slot2.visible = true
	racc_slot3.visible = true
	
	racc_slot1.mouse_entered.connect(_on_slot_hovered.bind(racc_slot1))
	racc_slot1.mouse_exited.connect(_on_slot_unhovered.bind(racc_slot1))
	racc_slot2.mouse_entered.connect(_on_slot_hovered.bind(racc_slot2))
	racc_slot2.mouse_exited.connect(_on_slot_unhovered.bind(racc_slot2))
	racc_slot3.mouse_entered.connect(_on_slot_hovered.bind(racc_slot3))
	racc_slot3.mouse_exited.connect(_on_slot_unhovered.bind(racc_slot3))

func _on_button_button_down():
	NetworkManager.send_message("submit_turtle", Inventory.local_turtle[NetworkManager.sessionID])
	done_shopping = true
	
func _slot1():
	if done_shopping:
		return
	if Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] >= shop_item1.price:
		if Inventory.item_1[0] == "arm":
			Inventory.item_1[0] = await which_arm()
		
		Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] -= shop_item1.price
		$Gold.text = "Gold: $" + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"])
		if Inventory.local_turtle[NetworkManager.sessionID]["items"][Inventory.item_1[0]] != null:
			var old_item = get_item_path(Inventory.item_1[0], Inventory.item_1[1])
			if Inventory.item_1[0] == "leftArm" or Inventory.item_1[0] == "rightArm":
				return_to_item_pool("arm", Inventory.local_turtle[NetworkManager.sessionID]["items"][Inventory.item_1[0]])
			else:
				return_to_item_pool(Inventory.item_1[0], Inventory.local_turtle[NetworkManager.sessionID]["items"][Inventory.item_1[0]])
			Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] += (old_item.price / 2)
			Inventory.local_turtle[NetworkManager.sessionID]["items"][Inventory.item_1[0]] = null
			
		Inventory.local_turtle[NetworkManager.sessionID]["items"][Inventory.item_1[0]] = Inventory.item_1[1]
		inventoryTurt.equip()
		if Inventory.item_1[0] == "leftArm" or Inventory.item_1[0] == "rightArm":
			Inventory.item_1[0] = "arm"
		ItemPassivePool.total_pool[Inventory.item_1[0]].erase(Inventory.item_1[1])
		racc_slot1.visible = false
		inventory_items()
	
func _slot2():
	if done_shopping:
		return
	if Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] >= shop_item2.price:
		if Inventory.item_2[0] == "arm":
			Inventory.item_2[0] = await which_arm()
			
		Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] -= shop_item2.price
		$Gold.text = "Gold: $" + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"])
		if Inventory.local_turtle[NetworkManager.sessionID]["items"][Inventory.item_2[0]] != null:
			var old_item = get_item_path(Inventory.item_2[0], Inventory.item_2[1])
			if Inventory.item_2[0] == "leftArm" or Inventory.item_2[0] == "rightArm":
				return_to_item_pool("arm", Inventory.local_turtle[NetworkManager.sessionID]["items"][Inventory.item_2[0]])
			else:
				return_to_item_pool(Inventory.item_2[0], Inventory.local_turtle[NetworkManager.sessionID]["items"][Inventory.item_2[0]])
			Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] += (old_item.price / 2)
			Inventory.local_turtle[NetworkManager.sessionID]["items"][Inventory.item_2[0]] = null
			
		Inventory.local_turtle[NetworkManager.sessionID]["items"][Inventory.item_2[0]] = Inventory.item_2[1]
		inventoryTurt.equip()
		if Inventory.item_2[0] == "leftArm" or Inventory.item_2[0] == "rightArm":
			Inventory.item_2[0] = "arm"
		ItemPassivePool.total_pool[Inventory.item_2[0]].erase(Inventory.item_2[1])
		racc_slot2.visible = false
		inventory_items()

func _slot3(): 
	if done_shopping:
		return
	if Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] >= shop_item3.price:
		if Inventory.item_3[0] == "arm":
			Inventory.item_3[0] = await which_arm()
			

		Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] -= shop_item3.price
		$Gold.text = "Gold: $" + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"])
		if Inventory.local_turtle[NetworkManager.sessionID]["items"][Inventory.item_3[0]] != null:
			var old_item = get_item_path(Inventory.item_3[0], Inventory.item_3[1])
			if Inventory.item_3[0] == "leftArm" or Inventory.item_3[0] == "rightArm":
				return_to_item_pool("arm", Inventory.local_turtle[NetworkManager.sessionID]["items"][Inventory.item_3[0]])
			else:
				return_to_item_pool(Inventory.item_3[0], Inventory.local_turtle[NetworkManager.sessionID]["items"][Inventory.item_3[0]])
			Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] += (old_item.price / 2)
			Inventory.local_turtle[NetworkManager.sessionID]["items"][Inventory.item_3[0]] = null
			
		Inventory.local_turtle[NetworkManager.sessionID]["items"][Inventory.item_3[0]] = Inventory.item_3[1]
		inventoryTurt.equip()
		if Inventory.item_3[0] == "leftArm" or Inventory.item_3[0] == "rightArm":
			Inventory.item_3[0] = "arm"
		ItemPassivePool.total_pool[Inventory.item_3[0]].erase(Inventory.item_3[1])
		racc_slot3.visible = false
		inventory_items()

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
	racc_slot1.disabled = true
	racc_slot2.disabled = true
	racc_slot3.disabled = true
	
	$leftArm.visible = true
	$rightArm.visible = true
	$whichArm.visible = true
	var arm = await button_selected
	return arm
	
func _on_left_arm():
	$Button.disabled = false
	racc_slot1.disabled = false
	racc_slot2.disabled = false
	racc_slot3.disabled = false
	
	$leftArm.visible = false
	$rightArm.visible = false
	$whichArm.visible = false
	button_selected.emit("leftArm")
	
func _on_right_arm():
	$Button.disabled = false
	racc_slot1.disabled = false
	racc_slot2.disabled = false
	racc_slot3.disabled = false
		
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
	if button == racc_slot1:
		item = shop_item1
	elif button == racc_slot2:
		item = shop_item2
	elif button == racc_slot3:
		item = shop_item3
	elif button == head_image:
		item = head_path
	elif button == shell_image:
		item = shell_path
	elif button == leftArm_image:
		item = leftArm_path
	elif button == rightArm_image:
		item = rightArm_path
	elif button == legs_image:
		item = legs_path

	$Tooltop.show_item(item)
	$Tooltop.global_position = button.global_position + Vector2(0, -500)

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

func inventory_items():
	if Inventory.local_turtle[NetworkManager.sessionID]["items"]["head"] != null:
		head_path = get_item_path("head", Inventory.local_turtle[NetworkManager.sessionID]["items"]["head"])
		head_image.texture = head_path.icon
		head_image.size = Vector2(32, 32)
		head_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		head_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		head_image.mouse_entered.connect(_on_slot_hovered.bind(head_image))
		head_image.mouse_exited.connect(_on_slot_unhovered.bind(head_image))
	if Inventory.local_turtle[NetworkManager.sessionID]["items"]["shell"] != null:
		shell_path = get_item_path("shell", Inventory.local_turtle[NetworkManager.sessionID]["items"]["shell"])
		shell_image.texture = shell_path.icon
		shell_image.mouse_entered.connect(_on_slot_hovered.bind(shell_image))
		shell_image.mouse_exited.connect(_on_slot_unhovered.bind(shell_image))
		shell_image.size = Vector2(32, 32)
		shell_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		shell_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if Inventory.local_turtle[NetworkManager.sessionID]["items"]["leftArm"] != null:
		leftArm_path = get_item_path("leftArm", Inventory.local_turtle[NetworkManager.sessionID]["items"]["leftArm"])
		leftArm_image.texture = leftArm_path.icon
		leftArm_image.mouse_entered.connect(_on_slot_hovered.bind(leftArm_image))
		leftArm_image.mouse_exited.connect(_on_slot_unhovered.bind(leftArm_image))
		leftArm_image.size = Vector2(32, 32)
		leftArm_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		leftArm_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if Inventory.local_turtle[NetworkManager.sessionID]["items"]["rightArm"] != null:
		rightArm_path = get_item_path("rightArm", Inventory.local_turtle[NetworkManager.sessionID]["items"]["rightArm"])
		rightArm_image.texture = rightArm_path.icon
		rightArm_image.mouse_entered.connect(_on_slot_hovered.bind(rightArm_image))
		rightArm_image.mouse_exited.connect(_on_slot_unhovered.bind(rightArm_image))
		rightArm_image.size = Vector2(32, 32)
		rightArm_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rightArm_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	if Inventory.local_turtle[NetworkManager.sessionID]["items"]["legs"] != null:
		legs_path = get_item_path("legs", Inventory.local_turtle[NetworkManager.sessionID]["items"]["legs"])
		legs_image.texture = legs_path.icon
		legs_image.mouse_entered.connect(_on_slot_hovered.bind(legs_image))
		legs_image.mouse_exited.connect(_on_slot_unhovered.bind(legs_image))
		legs_image.size = Vector2(32, 32)
		legs_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		legs_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED


func inventory_update():
	$InventoryPanel/StatsVBox/Acceleration.text = "Acceleration: " + str(Inventory.local_turtle[NetworkManager.sessionID]["base_stats"]["acceleration"])
	$"InventoryPanel/StatsVBox/Top Speed".text = "Top Speed: " + str(Inventory.local_turtle[NetworkManager.sessionID]["base_stats"]["max_speed"])
	$InventoryPanel/StatsVBox/Resilience.text = "Resilience: " + str(Inventory.local_turtle[NetworkManager.sessionID]["base_stats"]["resilience"])
	$"InventoryPanel/StatsVBox/Fire Rate".text = "Fire Rate: " + str(Inventory.local_turtle[NetworkManager.sessionID]["base_stats"]["fire_rate"])
	$"InventoryPanel/StatsVBox/Projectile Speed".text = "Projectile Speed: " + str(Inventory.local_turtle[NetworkManager.sessionID]["base_stats"]["projectile_speed"])
	$InventoryPanel/StatsVBox/Luck.text = "Luck: " + str(Inventory.local_turtle[NetworkManager.sessionID]["base_stats"]["luck"])
	
