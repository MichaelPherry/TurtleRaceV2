extends Control

@onready var inventoryTurt = $InPanel/InventoryTurtle
@onready var hover_button = $InPanel/HoverButton
@onready var head_image = $InPanel/ItemsVBox/Items/Head
@onready var shell_image = $InPanel/ItemsVBox/Items/Shell
@onready var leftArm_image = $InPanel/ItemsVBox/Items/LeftArm
@onready var rightArm_image = $InPanel/ItemsVBox/Items/RightArm
@onready var legs_image = $InPanel/ItemsVBox/Items/Legs
@onready var self_inven = $InPanel/SelfInventory
@onready var opp1_inven = $InPanel/Opponent1
@onready var opp2_inven = $InPanel/Opponent2
@onready var opp3_inven = $InPanel/Opponent3
@onready var stck1 = $InPanel/StatsVBox/Stock1
@onready var stck2 = $InPanel/StatsVBox/Stock2
@onready var stck3 = $InPanel/StatsVBox/Stock3
@onready var stck4 = $InPanel/StatsVBox/Stock4
@onready var tooltip = $InPanel/Tooltop

var head_path
var shell_path
var leftArm_path
var rightArm_path
var legs_path

var player_ids
var self_sid
var opp1_sid
var opp2_sid
var opp3_sid
var self_label 
var opp1_label
var opp2_label
var opp3_label

var stock_names
var stock_labels

func _ready() -> void:
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

	$InPanel.visible = false
	$InventoryButton.visible = true
	$InPanel/PlayerName.text = str(NetworkManager.local_player_name)

	hover_button.mouse_entered.connect(_on_inventory_turtle_hovered)
	hover_button.mouse_exited.connect(_on_inventory_turtle_unhovered)
	
	stck1.visible = false
	stck2.visible = false
	stck3.visible = false
	stck4.visible = false
	
	stock_names = []
	stock_labels = [stck1, stck2, stck3, stck4]
	if Inventory.server_turtles.size() > 0:
		for player in range(Inventory.id_list.size()):
			stock_names.append(Inventory.stock_finder(Inventory.id_list[player]))
	
	inventory_items()
	inventory_update()


func _on_slot_hovered(button):
	create_tween().tween_property(button, "scale", Vector2(1.1, 1.1), 0.1)
	button.modulate = Color(1.3, 1.3, 1.3)
	var item
	if button == head_image:
		item = head_path
	elif button == shell_image:
		item = shell_path
	elif button == leftArm_image:
		item = leftArm_path
	elif button == rightArm_image:
		item = rightArm_path
	elif button == legs_image:
		item = legs_path
	tooltip.show_item(item)
	tooltip.global_position = button.global_position + Vector2(0, -500)

func _on_slot_unhovered(button):
	create_tween().tween_property(button, "scale", Vector2.ONE, 0.1)
	button.modulate = Color.WHITE
	tooltip.hide_tooltip()

func _on_inventory_button_pressed() -> void:
	inventoryTurt.local_equip()
	inventory_items()
	inventory_update()
	#hud.visible = false
	$InPanel.visible = true
	$InventoryButton.visible = false

func _on_hide_inventory_pressed() -> void:
	$InPanel.visible = false
	$InventoryButton.visible = true
	#hud.visible = true

func _on_inventory_turtle_hovered():
	inventoryTurt.hover()

func _on_inventory_turtle_unhovered():
	inventoryTurt.unhover()

func inventory_items():
	head_image.texture = null
	shell_image.texture = null
	leftArm_image.texture = null
	rightArm_image.texture = null
	legs_image.texture = null
	image_disconnect()
	$InPanel/PlayerName.text = str(NetworkManager.local_player_name)
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
	$InPanel/PlayerName.text = str(Inventory.label_finder(sid))
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
	$InPanel/StatsVBox/Acceleration.text = "Acceleration: " + str(Inventory.local_turtle[NetworkManager.sessionID]["base_stats"]["acceleration"])
	$"InPanel/StatsVBox/Top Speed".text = "Top Speed: " + str(Inventory.local_turtle[NetworkManager.sessionID]["base_stats"]["max_speed"])
	$InPanel/StatsVBox/Resilience.text = "Resilience: " + str(Inventory.local_turtle[NetworkManager.sessionID]["base_stats"]["resilience"])
	$"InPanel/StatsVBox/Fire Rate".text = "Fire Rate: " + str(Inventory.local_turtle[NetworkManager.sessionID]["base_stats"]["fire_rate"])
	$"InPanel/StatsVBox/Projectile Speed".text = "Projectile Speed: " + str(Inventory.local_turtle[NetworkManager.sessionID]["base_stats"]["projectile_speed"])
	$InPanel/StatsVBox/Luck.text = "Luck: " + str(Inventory.local_turtle[NetworkManager.sessionID]["base_stats"]["luck"])
	$InPanel/StatsVBox/Gold.text = "Gold: " + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"])
	if Inventory.server_turtles.size() > 0:
		for stock in range(stock_names.size()):
			stock_labels[stock].visible = true
			stock_labels[stock].text = str(stock_names[stock]) + ": " + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["stock" + str(stock + 1)])

func inventory_opponent_update(sid):
	$InPanel/StatsVBox/Acceleration.text = "Acceleration: " + str(Inventory.server_turtles[sid]["base_stats"]["acceleration"])
	$"InPanel/StatsVBox/Top Speed".text = "Top Speed: " + str(Inventory.server_turtles[sid]["base_stats"]["max_speed"])
	$InPanel/StatsVBox/Resilience.text = "Resilience: " + str(Inventory.server_turtles[sid]["base_stats"]["resilience"])
	$"InPanel/StatsVBox/Fire Rate".text = "Fire Rate: " + str(Inventory.server_turtles[sid]["base_stats"]["fire_rate"])
	$"InPanel/StatsVBox/Projectile Speed".text = "Projectile Speed: " + str(Inventory.server_turtles[sid]["base_stats"]["projectile_speed"])
	$InPanel/StatsVBox/Luck.text = "Luck: " + str(Inventory.server_turtles[sid]["base_stats"]["luck"])
	$InPanel/StatsVBox/Gold.text = "Gold: " + str(Inventory.server_turtles[sid]["econ"]["gold"])
	if Inventory.server_turtles.size() > 0:
		for stock in range(stock_names.size()):
			stock_labels[stock].visible = true
			stock_labels[stock].text = str(stock_names[stock]) + ": " + str(Inventory.server_turtles[sid]["econ"]["stock" + str(stock + 1)])

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

func get_item_path(body_part, item_name):
	if body_part == "leftArm" or body_part == "rightArm":
		body_part = "arm"
	var tres_instance = ItemPassivePool.call(body_part, item_name)
	return tres_instance
