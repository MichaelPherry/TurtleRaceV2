extends Node2D

@onready var background = $RaccoonBackground
@onready var racc_slot1 = $RaccoonBackground/slot1
@onready var racc_slot2 = $RaccoonBackground/slot2
@onready var racc_slot3 = $RaccoonBackground/slot3
@onready var hud = $RaccoonBackground/shopHUD
@onready var head_hud = $RaccoonBackground/shopHUD/Inventory/ItemContainer/HeadSlot/Head
@onready var shell_hud = $RaccoonBackground/shopHUD/Inventory/ItemContainer/ShellSlot/Shell
@onready var leftArm_hud = $RaccoonBackground/shopHUD/Inventory/ItemContainer/LeftArmSlot/LeftArm
@onready var rightArm_hud = $RaccoonBackground/shopHUD/Inventory/ItemContainer/RightArmSlot/RightArm
@onready var legs_hud = $RaccoonBackground/shopHUD/Inventory/ItemContainer/LegsSlot/Legs

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
var text_color = Color.WHITE

func _ready():
	$Boss.visible = false
	if Inventory.server_turtles.size() > 0:
		var self_label = NetworkManager.local_player_name
		var self_sid = Inventory.sid_finder(self_label)
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

	item_roll()
	
	id = NetworkManager.sessionID
	hud.icon_setup()

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
	MusicManager.play_effect("button_click")
	hud.icon_setup()
	
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
	MusicManager.play_effect("button_click")
	hud.icon_setup()

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
	MusicManager.play_effect("button_click")
	hud.icon_setup()

func rand_items():
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

func _on_roll_pressed() -> void:
	if done_shopping:
		return

	if Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] < roll_cost:
		shake_gold()
		return
		
	Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] -= roll_cost
	temp_pool = ItemPassivePool.total_pool.duplicate(true)
	MusicManager.play_effect("button_click")
	$Gold.text = "Gold: " + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"])
	item_roll()

func _on_item_sold():
	$Gold.text = "Gold: " + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"])

func shake(item_slot):
	if shake_tween and shake_tween.is_running():
		shake_tween.kill()
	
	var original_position = item_slot.position
	MusicManager.play_effect("button_error")
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
	var original_color = text_color
	
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
	MusicManager.play_effect("button_error")
	message_tween = create_tween()
	message_tween.tween_interval(0.6)
	message_tween.tween_property($InventoryFull, "modulate:a", 0.0, 0.3)
	message_tween.tween_callback($InventoryFull.hide)
	
	await get_tree().create_timer(0.7).timeout
	
	if Inventory.main_hud == false:
		$RaccoonBackground/shopHUD._on_toggle_hud_pressed()

func _on_ready_pressed() -> void:
	MusicManager.play_effect("button_click")
	NetworkManager.send_message("submit_turtle", Inventory.local_turtle[NetworkManager.sessionID])
	done_shopping = true


func _on_boss_pressed() -> void:
	MusicManager.play_effect("button_click")
	NetworkManager.send_message("request_boss_race", "request_boss_race")
	NetworkManager.send_message("submit_turtle", Inventory.local_turtle[NetworkManager.sessionID])
	done_shopping = true
