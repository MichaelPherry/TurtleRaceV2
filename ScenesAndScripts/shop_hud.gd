extends CanvasLayer

@onready var head = $Inventory/ItemContainer/HeadSlot/Head
@onready var shell = $Inventory/ItemContainer/ShellSlot/Shell
@onready var leftArm = $Inventory/ItemContainer/LeftArmSlot/LeftArm
@onready var rightArm = $Inventory/ItemContainer/RightArmSlot/RightArm
@onready var legs = $Inventory/ItemContainer/LegsSlot/Legs
@onready var hud_inventory = $Inventory
@onready var hud_tog =  $ToggleHUD

var invetory_item_scene = preload("res://ScenesAndScripts/inventory_item.tscn")
var head_path
var head_image
var shell_path
var shell_image
var leftArm_path
var leftArm_image
var rightArm_path
var rightArm_image
var legs_path
var legs_image
var inventory_item

var tween
var open_position
var closed_position
var open_tog_position
var closed_tog_position

var items = []

func _ready() -> void:
	open_position = hud_inventory.position
	closed_position = open_position + Vector2(0, hud_inventory.size.y)
	open_tog_position = hud_tog.position
	closed_tog_position = open_tog_position + Vector2(0, hud_inventory.size.y - hud_tog.size.y)
	
	if Inventory.main_hud == true:
		hud_tog.text = "-"
		hud_inventory.position = open_position
		hud_tog.position = open_tog_position
	else:
		hud_tog.text = "+"
		hud_inventory.position = closed_position
		hud_tog.position = closed_tog_position

func icon_setup():
	if Inventory.local_turtle[NetworkManager.sessionID]["items"]["head"] != null:
		head_path = get_item_path("head", Inventory.local_turtle[NetworkManager.sessionID]["items"]["head"])
		head.setup("head", head_path)
		items.append("head")
	
	if Inventory.local_turtle[NetworkManager.sessionID]["items"]["shell"] != null:
		shell_path = get_item_path("shell", Inventory.local_turtle[NetworkManager.sessionID]["items"]["shell"])
		shell.setup("shell", shell_path)
		items.append("shell")
		
	if Inventory.local_turtle[NetworkManager.sessionID]["items"]["leftArm"] != null:
		leftArm_path = get_item_path("leftArm", Inventory.local_turtle[NetworkManager.sessionID]["items"]["leftArm"])
		leftArm.setup("leftArm", leftArm_path)
		items.append("leftArm")
		
	if Inventory.local_turtle[NetworkManager.sessionID]["items"]["rightArm"] != null:
		rightArm_path = get_item_path("rightArm", Inventory.local_turtle[NetworkManager.sessionID]["items"]["rightArm"])
		rightArm.setup("rightArm", rightArm_path)
		items.append("rightArm")
		
	if Inventory.local_turtle[NetworkManager.sessionID]["items"]["legs"] != null:
		legs_path = get_item_path("legs", Inventory.local_turtle[NetworkManager.sessionID]["items"]["legs"])
		legs.setup("legs", legs_path)
		items.append("legs")
		
func get_item_path(body_part, item_name):
	if body_part == "leftArm" or body_part == "rightArm":
		body_part = "arm"
	var tres_instance = ItemPassivePool.call(body_part, item_name)
	return tres_instance


func _on_toggle_hud_pressed() -> void:
	if tween and tween.is_running():
		tween.kill()
	
	tween = create_tween()
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.set_ease(Tween.EASE_OUT)
	tween.set_parallel(true)
	
	if Inventory.main_hud == true:
		tween.tween_property(hud_inventory, "position", closed_position, 0.3)
		tween.tween_property(hud_tog, "position", closed_tog_position, 0.3)
		hud_tog.text = "+"
		Inventory.main_hud = false
		
	else:
		tween.tween_property(hud_inventory, "position", open_position, 0.3)
		tween.tween_property(hud_tog, "position", open_tog_position, 0.3)
		hud_tog.text = "-"
		Inventory.main_hud = true
