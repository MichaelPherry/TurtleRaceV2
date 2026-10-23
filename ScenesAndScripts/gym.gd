extends Node2D

@onready var background = $RaccoonBackground
@onready var rat_slot1 = $RatBackground/gymslot1
@onready var rat_slot2 = $RatBackground/gymslot2
@onready var rat_slot3 = $RatBackground/gymslot3



var head_path
var shell_path
var leftArm_path
var rightArm_path
var legs_path

var shop_item_icons = []
var gym_item1
var gym_item2
var gym_item3
var id
var done_shopping = false
var shop_time = 40
var temp_pool
var roll_counter
signal button_selected(button_name)

func _ready():
	Inventory.start = false

	roll_counter = 1
	gym_roll()
	

func _process(delta):
	pass

func gym_roll():
	rand_buff()
	Inventory.buff_1 = gym_item1
	Inventory.buff_2 = gym_item2
	Inventory.buff_3 = gym_item3
	
	gym_item1 = get_item_path("stat_buff", Inventory.buff_1)
	gym_item2 = get_item_path("stat_buff", Inventory.buff_2)
	gym_item3 = get_item_path("stat_buff", Inventory.buff_3)
	
	rat_slot1.texture_normal = gym_item1.icon
	rat_slot2.texture_normal = gym_item2.icon
	rat_slot3.texture_normal = gym_item3.icon
	$RatBackground/gymslot1/slot1_cost.text = "$" + str(gym_item1.price)
	$RatBackground/gymslot2/slot2_cost.text = "$" + str(gym_item2.price)
	$RatBackground/gymslot3/slot3_cost.text = "$" + str(gym_item3.price)
	
	rat_slot1.visible = true
	rat_slot2.visible = true
	rat_slot3.visible = true
	
	rat_slot1.mouse_entered.connect(_on_slot_hovered.bind(rat_slot1))
	rat_slot1.mouse_exited.connect(_on_slot_unhovered.bind(rat_slot1))
	rat_slot2.mouse_entered.connect(_on_slot_hovered.bind(rat_slot2))
	rat_slot2.mouse_exited.connect(_on_slot_unhovered.bind(rat_slot2))
	rat_slot3.mouse_entered.connect(_on_slot_hovered.bind(rat_slot3))
	rat_slot3.mouse_exited.connect(_on_slot_unhovered.bind(rat_slot3))

func rand_buff():
	var buffs = ItemPassivePool.all_buffs.duplicate()
	buffs.shuffle()
	var random_buffs = buffs.slice(0,3)
	gym_item1 = random_buffs[0]
	gym_item2 = random_buffs[1]
	gym_item3 = random_buffs[2]

func _on_slot_hovered(button):
	create_tween().tween_property(button, "scale", Vector2(1.1, 1.1), 0.1)
	button.modulate = Color(1.3, 1.3, 1.3)
	var item
	if button == rat_slot1:
		item = gym_item1
	elif button == rat_slot2:
		item = gym_item2
	elif button == rat_slot3:
		item = gym_item3
		
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

func _on_roll_pressed() -> void:
	if done_shopping:
		return
	if Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] >= 5:
		Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] -= 5
		$Gold.text = "Gold: $" + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"])
		gym_roll()

func _on_gymslot_1_pressed() -> void:
	if done_shopping:
		return
	if Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] >= gym_item1.price:
			Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] -= gym_item1.price
			$Gold.text = "Gold: $" + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"])
			var scene_buff = gym_item1.buff_scene.instantiate()
			scene_buff.apply()
			rat_slot1.visible = false
			scene_buff = null
			
func _on_gymslot_2_pressed() -> void:
	if done_shopping:
		return
	if Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] >= gym_item2.price:
			Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] -= gym_item2.price
			$Gold.text = "Gold: $" + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"])
			var scene_buff = gym_item2.buff_scene.instantiate()
			scene_buff.apply()
			rat_slot2.visible = false
			scene_buff = null
			
func _on_gymslot_3_pressed() -> void:
	if done_shopping:
		return
	if Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] >= gym_item3.price:
			Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] -= gym_item3.price
			$Gold.text = "Gold: $" + str(Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"])
			var scene_buff = gym_item3.buff_scene.instantiate()
			scene_buff.apply()
			rat_slot3.visible = false
			scene_buff = null

func get_item_path(body_part, item_name):
	if body_part == "leftArm" or body_part == "rightArm":
		body_part = "arm"
	var tres_instance = ItemPassivePool.call(body_part, item_name)
	return tres_instance

func _on_shop_pressed() -> void:
	get_tree().change_scene_to_file("res://ScenesAndScripts/shop.tscn")
