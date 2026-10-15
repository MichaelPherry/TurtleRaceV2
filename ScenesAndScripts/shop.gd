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
@onready var hud = $RaccoonBackground/shopHUD
@onready var head_hud = $RaccoonBackground/shopHUD/Inventory/ItemContainer/HeadSlot/Head
@onready var shell_hud = $RaccoonBackground/shopHUD/Inventory/ItemContainer/ShellSlot/Shell
@onready var leftArm_hud = $RaccoonBackground/shopHUD/Inventory/ItemContainer/LeftArmSlot/LeftArm
@onready var rightArm_hud = $RaccoonBackground/shopHUD/Inventory/ItemContainer/RightArmSlot/RightArm
@onready var legs_hud = $RaccoonBackground/shopHUD/Inventory/ItemContainer/LegsSlot/Legs
@onready var self_inven = $InventoryPanel/SelfInventory
@onready var opp1_inven = $InventoryPanel/Opponent1
@onready var opp2_inven = $InventoryPanel/Opponent2
@onready var opp3_inven = $InventoryPanel/Opponent3

var head_path
var shell_path
var leftArm_path
var rightArm_path
var legs_path

var shop_item_icons = []
var shop_item1
var shop_item2
var shop_item3
var player_ids
var id
var done_shopping = false
var shop_time = 60
var temp_pool
var roll_counter
var roll_cost = 5
signal button_selected(button_name)

var self_sid
var opp1_sid
var opp2_sid
var opp3_sid
var self_label 
var opp1_label
var opp2_label
var opp3_label

var shake_tween
var gold_tween
var message_tween

func _ready():
	$Boss.visible = false
	if Inventory.server_turtles.size() == 0:
		opp1_inven.visible = false
		opp2_inven.visible = false
		opp3_inven.visible = false
		self_inven.visible = false
	else:
		head_image.size = Vector2(32, 32)
		head_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		head_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		shell_image.size = Vector2(32, 32)
		shell_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		shell_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		leftArm_image.size = Vector2(32, 32)
		leftArm_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		leftArm_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		rightArm_image.size = Vector2(32, 32)
		rightArm_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		rightArm_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		legs_image.size = Vector2(32, 32)
		legs_image.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		legs_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		player_ids = Inventory.id_list.duplicate()
		player_ids.erase(NetworkManager.local_player_name)
		self_label = NetworkManager.local_player_name
		self_sid = Inventory.sid_finder(self_label)
		player_ids.erase(self_sid)
		if Inventory.server_turtles.keys().size() > 1:
			opp1_sid = player_ids.pop_front()
			opp1_label = Inventory.label_finder(opp1_sid)
			opp1_inven.text = opp1_label
			opp1_inven.visible = true
		else:
			opp1_inven.visible = false
		if Inventory.server_turtles.keys().size() > 2:
			opp2_sid = player_ids.pop_front()
			opp2_label = Inventory.label_finder(opp2_sid)
			opp2_inven.text = opp2_label
			opp2_inven.visible = true
		else:
			opp2_inven.visible = false
		if Inventory.server_turtles.keys().size() > 3:
			opp3_sid = player_ids.pop_front()
			opp3_label = Inventory.label_finder(opp3_sid)
			opp3_inven.text = opp3_label
			opp3_inven.visible = true
		else:
			opp3_inven.visible = false
		self_inven.text = self_label
		self_inven.visible = true
		if Inventory.server_turtles[self_sid]["results"]["first"] >= Inventory.wins_needed_for_boss:
			$Boss.visible = true
	
	Inventory.start = false
	MusicManager.mainmenu.stop()
	MusicManager.fade_in()
	done_shopping = false
	temp_pool = ItemPassivePool.total_pool.duplicate(true)
	$Roll.visible = true
	$Gold.modulate = Color.WHITE
	$Label.modulate = Color.WHITE
	
	
	head_hud.item_sold.connect(_on_item_sold)
	shell_hud.item_sold.connect(_on_item_sold)
	leftArm_hud.item_sold.connect(_on_item_sold)
	rightArm_hud.item_sold.connect(_on_item_sold)
	legs_hud.item_sold.connect(_on_item_sold)
	
	roll_counter = -1
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
	hud.icon_setup()
	
	id = NetworkManager.sessionID

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
	roll_counter += 1
	if roll_counter >= 2:
		$Roll.visible = false
		
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
	
func _slot1():
	if done_shopping:
		return
	if Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] < shop_item1.price:
		shake_gold()
		shake(racc_slot1)
		return
		
	if Inventory.item_1[0] == "arm":
		if typeof(has_arm_space()) == TYPE_BOOL:
			inventory_full()
			return
		else:
			Inventory.item_1[0] = has_arm_space()
	else: 
		if has_space(Inventory.item_1[0]) == false:
			inventory_full()
			return
	
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
	#inventoryTurt.equip()
	if Inventory.item_1[0] == "leftArm" or Inventory.item_1[0] == "rightArm":
		Inventory.item_1[0] = "arm"
	ItemPassivePool.total_pool[Inventory.item_1[0]].erase(Inventory.item_1[1])
	racc_slot1.visible = false
	hud.icon_setup()
	inventory_items()
	
func _slot2():
	if done_shopping:
		return
	if Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] < shop_item2.price:
		shake_gold()
		shake(racc_slot2)
		return
		
	if Inventory.item_2[0] == "arm":
		if typeof(has_arm_space()) == TYPE_BOOL:
			inventory_full()
			return
		else:
			Inventory.item_2[0] = has_arm_space()
	else: 
		if has_space(Inventory.item_2[0]) == false:
			inventory_full()
			return
		
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
	#inventoryTurt.equip()
	if Inventory.item_2[0] == "leftArm" or Inventory.item_2[0] == "rightArm":
		Inventory.item_2[0] = "arm"
	ItemPassivePool.total_pool[Inventory.item_2[0]].erase(Inventory.item_2[1])
	racc_slot2.visible = false
	hud.icon_setup()
	inventory_items()

func _slot3(): 
	if done_shopping:
		return
	if Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] < shop_item3.price:
		shake_gold()
		shake(racc_slot3)
		return
		
	if Inventory.item_3[0] == "arm":
		if typeof(has_arm_space()) == TYPE_BOOL:
			inventory_full()
			return
		else:
			Inventory.item_3[0] = has_arm_space()
	else: 
		if has_space(Inventory.item_3[0]) == false:
			inventory_full()
			return

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
	#inventoryTurt.equip()
	if Inventory.item_3[0] == "leftArm" or Inventory.item_3[0] == "rightArm":
		Inventory.item_3[0] = "arm"
	ItemPassivePool.total_pool[Inventory.item_3[0]].erase(Inventory.item_3[1])
	racc_slot3.visible = false
	hud.icon_setup()
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

func has_space(appendage):
	if Inventory.local_turtle[NetworkManager.sessionID]["items"][appendage] == null:
		return true
	else:
		return false

func has_arm_space():
	if Inventory.local_turtle[NetworkManager.sessionID]["items"]["leftArm"] == null:
		return "leftArm"
	elif Inventory.local_turtle[NetworkManager.sessionID]["items"]["rightArm"] == null:
		return "rightArm"
	else:
		return false

func _on_inventory_button_pressed() -> void:
	inventoryTurt.local_equip()
	inventory_items()
	inventory_update()
	hud.visible = false
	$InventoryPanel.visible = true
	#create_tween().tween_property($InventoryPanel, "position:x", 1100, 0.2)

func _on_hide_inventory_pressed() -> void:
	$InventoryPanel.visible = false
	hud.visible = true

func _on_inventory_turtle_hovered():
	inventoryTurt.hover()

func _on_inventory_turtle_unhovered():
	inventoryTurt.unhover()

func _on_roll_pressed() -> void:
	if done_shopping:
		return

	if Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] < roll_cost:
		shake_gold()
		return
		
	Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] -= roll_cost
	temp_pool = ItemPassivePool.total_pool.duplicate(true)
	$Gold.text = "Gold: $" + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"])
	item_roll()

func inventory_items():
	head_image.texture = null
	shell_image.texture = null
	leftArm_image.texture = null
	rightArm_image.texture = null
	legs_image.texture = null
	image_disconnect()
	if Inventory.local_turtle[NetworkManager.sessionID]["items"]["head"] != null:
		head_path = get_item_path("head", Inventory.local_turtle[NetworkManager.sessionID]["items"]["head"])
		head_image.texture = head_path.icon
		head_image.mouse_entered.connect(_on_slot_hovered.bind(head_image))
		head_image.mouse_exited.connect(_on_slot_unhovered.bind(head_image))
	if Inventory.local_turtle[NetworkManager.sessionID]["items"]["shell"] != null:
		shell_path = get_item_path("shell", Inventory.local_turtle[NetworkManager.sessionID]["items"]["shell"])
		shell_image.texture = shell_path.icon
		shell_image.mouse_entered.connect(_on_slot_hovered.bind(shell_image))
		shell_image.mouse_exited.connect(_on_slot_unhovered.bind(shell_image))
	if Inventory.local_turtle[NetworkManager.sessionID]["items"]["leftArm"] != null:
		leftArm_path = get_item_path("leftArm", Inventory.local_turtle[NetworkManager.sessionID]["items"]["leftArm"])
		leftArm_image.texture = leftArm_path.icon
		leftArm_image.mouse_entered.connect(_on_slot_hovered.bind(leftArm_image))
		leftArm_image.mouse_exited.connect(_on_slot_unhovered.bind(leftArm_image))
	if Inventory.local_turtle[NetworkManager.sessionID]["items"]["rightArm"] != null:
		rightArm_path = get_item_path("rightArm", Inventory.local_turtle[NetworkManager.sessionID]["items"]["rightArm"])
		rightArm_image.texture = rightArm_path.icon
		rightArm_image.mouse_entered.connect(_on_slot_hovered.bind(rightArm_image))
		rightArm_image.mouse_exited.connect(_on_slot_unhovered.bind(rightArm_image))
	if Inventory.local_turtle[NetworkManager.sessionID]["items"]["legs"] != null:
		legs_path = get_item_path("legs", Inventory.local_turtle[NetworkManager.sessionID]["items"]["legs"])
		legs_image.texture = legs_path.icon
		legs_image.mouse_entered.connect(_on_slot_hovered.bind(legs_image))
		legs_image.mouse_exited.connect(_on_slot_unhovered.bind(legs_image))

func inventory_opponent_items(sid):
	head_image.texture = null
	shell_image.texture = null
	leftArm_image.texture = null
	rightArm_image.texture = null
	legs_image.texture = null
	image_disconnect()
	if Inventory.server_turtles[sid]["items"]["head"] != null:
		head_path = get_item_path("head", Inventory.server_turtles[sid]["items"]["head"])
		head_image.texture = head_path.icon
		head_image.mouse_entered.connect(_on_slot_hovered.bind(head_image))
		head_image.mouse_exited.connect(_on_slot_unhovered.bind(head_image))
	if Inventory.server_turtles[sid]["items"]["shell"] != null:
		shell_path = get_item_path("shell", Inventory.server_turtles[sid]["items"]["shell"])
		shell_image.texture = shell_path.icon
		shell_image.mouse_entered.connect(_on_slot_hovered.bind(shell_image))
		shell_image.mouse_exited.connect(_on_slot_unhovered.bind(shell_image))
	if Inventory.server_turtles[sid]["items"]["leftArm"] != null:
		leftArm_path = get_item_path("leftArm", Inventory.server_turtles[sid]["items"]["leftArm"])
		leftArm_image.texture = leftArm_path.icon
		leftArm_image.mouse_entered.connect(_on_slot_hovered.bind(leftArm_image))
		leftArm_image.mouse_exited.connect(_on_slot_unhovered.bind(leftArm_image))
	if Inventory.server_turtles[sid]["items"]["rightArm"] != null:
		rightArm_path = get_item_path("rightArm", Inventory.server_turtles[sid]["items"]["rightArm"])
		rightArm_image.texture = rightArm_path.icon
		rightArm_image.mouse_entered.connect(_on_slot_hovered.bind(rightArm_image))
		rightArm_image.mouse_exited.connect(_on_slot_unhovered.bind(rightArm_image))
	if Inventory.server_turtles[sid]["items"]["legs"] != null:
		legs_path = get_item_path("legs", Inventory.server_turtles[sid]["items"]["legs"])
		legs_image.texture = legs_path.icon
		legs_image.mouse_entered.connect(_on_slot_hovered.bind(legs_image))
		legs_image.mouse_exited.connect(_on_slot_unhovered.bind(legs_image))

func _on_item_sold():
	$Gold.text = "Gold: " + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"])

func _on_self_inventory_pressed():
	inventoryTurt.local_equip()
	inventory_items()
	inventory_update()

func _on_opponent_1_pressed():
	inventoryTurt.equip(opp1_sid)
	inventory_opponent_items(opp1_sid)
	inventory_opponent_update(opp1_sid)

func _on_opponent_2_pressed():
	inventoryTurt.equip(opp2_sid)
	inventory_opponent_items(opp2_sid)
	inventory_opponent_update(opp2_sid)

func _on_opponent_3_pressed():
	inventoryTurt.equip(opp3_sid)
	inventory_opponent_items(opp3_sid)
	inventory_opponent_update(opp3_sid)

func inventory_update():
	$InventoryPanel/StatsVBox/Acceleration.text = "Acceleration: " + str(Inventory.local_turtle[NetworkManager.sessionID]["base_stats"]["acceleration"])
	$"InventoryPanel/StatsVBox/Top Speed".text = "Top Speed: " + str(Inventory.local_turtle[NetworkManager.sessionID]["base_stats"]["max_speed"])
	$InventoryPanel/StatsVBox/Resilience.text = "Resilience: " + str(Inventory.local_turtle[NetworkManager.sessionID]["base_stats"]["resilience"])
	$"InventoryPanel/StatsVBox/Fire Rate".text = "Fire Rate: " + str(Inventory.local_turtle[NetworkManager.sessionID]["base_stats"]["fire_rate"])
	$"InventoryPanel/StatsVBox/Projectile Speed".text = "Projectile Speed: " + str(Inventory.local_turtle[NetworkManager.sessionID]["base_stats"]["projectile_speed"])
	$InventoryPanel/StatsVBox/Luck.text = "Luck: " + str(Inventory.local_turtle[NetworkManager.sessionID]["base_stats"]["luck"])
	$InventoryPanel/StatsVBox/Gold.text = "Gold: " + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"])

func inventory_opponent_update(sid):
	$InventoryPanel/StatsVBox/Acceleration.text = "Acceleration: " + str(Inventory.server_turtles[sid]["base_stats"]["acceleration"])
	$"InventoryPanel/StatsVBox/Top Speed".text = "Top Speed: " + str(Inventory.server_turtles[sid]["base_stats"]["max_speed"])
	$InventoryPanel/StatsVBox/Resilience.text = "Resilience: " + str(Inventory.server_turtles[sid]["base_stats"]["resilience"])
	$"InventoryPanel/StatsVBox/Fire Rate".text = "Fire Rate: " + str(Inventory.server_turtles[sid]["base_stats"]["fire_rate"])
	$"InventoryPanel/StatsVBox/Projectile Speed".text = "Projectile Speed: " + str(Inventory.server_turtles[sid]["base_stats"]["projectile_speed"])
	$InventoryPanel/StatsVBox/Luck.text = "Luck: " + str(Inventory.server_turtles[sid]["base_stats"]["luck"])
	$InventoryPanel/StatsVBox/Gold.text = "Gold: " + str(Inventory.server_turtles[sid]["econ"]["gold"])

func image_disconnect():
	head_image.mouse_entered.disconnect(_on_slot_hovered.bind(head_image))
	head_image.mouse_exited.disconnect(_on_slot_unhovered.bind(head_image))
	
	shell_image.mouse_entered.disconnect(_on_slot_hovered.bind(shell_image))
	shell_image.mouse_exited.disconnect(_on_slot_unhovered.bind(shell_image))

	leftArm_image.mouse_entered.disconnect(_on_slot_hovered.bind(leftArm_image))
	leftArm_image.mouse_exited.disconnect(_on_slot_unhovered.bind(leftArm_image))

	rightArm_image.mouse_entered.disconnect(_on_slot_hovered.bind(rightArm_image))
	rightArm_image.mouse_exited.disconnect(_on_slot_unhovered.bind(rightArm_image))

	legs_image.mouse_entered.disconnect(_on_slot_hovered.bind(legs_image))
	legs_image.mouse_exited.disconnect(_on_slot_unhovered.bind(legs_image))

func shake(item_slot):
	if shake_tween and shake_tween.is_running():
		shake_tween.kill()
	
	var original_position = item_slot.position
	shake_tween = create_tween()
	shake_tween.tween_property(item_slot, "position:x", original_position.x + 8, 0.04)
	shake_tween.tween_property(item_slot, "position:x", original_position.x - 8, 0.04)
	shake_tween.tween_property(item_slot, "position:x", original_position.x + 5, 0.04)
	shake_tween.tween_property(item_slot, "position:x", original_position.x - 5, 0.04)
	shake_tween.tween_property(item_slot, "position:x", original_position.x, 0.04)

func shake_gold():
	if gold_tween and gold_tween.is_running():
		gold_tween.kill()

	var original_position = $Gold.position
	var original_color = $Gold.modulate
	
	gold_tween = create_tween()
	gold_tween.set_parallel()
	
	gold_tween.tween_property($Gold, "modulate", Color.RED, 0.1).set_trans(Tween.TRANS_QUAD)
	gold_tween.tween_property($Gold, "position:x", original_position.x + 10, 0.04).set_delay(0.0)
	gold_tween.chain().tween_property($Gold, "position:x", original_position.x - 6, 0.04)
	gold_tween.chain().tween_property($Gold, "position:x", original_position.x + 4, 0.04)
	gold_tween.chain().tween_property($Gold, "position:x", original_position.x, 0.04)
	gold_tween.tween_property($Gold, "modulate", original_color, 0.2).set_delay(0.15)

func inventory_full():
	if message_tween and message_tween.is_running():
		message_tween.kill()

	if Inventory.main_hud == true:
		$RaccoonBackground/shopHUD._on_toggle_hud_pressed()
	
	$InventoryFull.show()
	$InventoryFull.modulate = Color.WHITE

	message_tween = create_tween()
	message_tween.tween_interval(0.6)
	message_tween.tween_property($InventoryFull, "modulate:a", 0.0, 0.3)
	message_tween.tween_callback($InventoryFull.hide)
	
	await get_tree().create_timer(0.7).timeout
	
	if Inventory.main_hud == false:
		$RaccoonBackground/shopHUD._on_toggle_hud_pressed()

func _on_ready_pressed() -> void:
	NetworkManager.send_message("submit_turtle", Inventory.local_turtle[NetworkManager.sessionID])
	done_shopping = true


func _on_boss_pressed() -> void:
	NetworkManager.send_message("request_boss_race", "request_boss_race")
	NetworkManager.send_message("submit_turtle", Inventory.local_turtle[NetworkManager.sessionID])
	done_shopping = true
