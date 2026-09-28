extends CanvasLayer

@onready var head = $Inventory/ItemContainer/Head
@onready var shell = $Inventory/ItemContainer/Shell
@onready var leftArm = $Inventory/ItemContainer/LeftArm
@onready var rightArm = $Inventory/ItemContainer/RightArm
@onready var legs = $Inventory/ItemContainer/Legs

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

var items = []

func _ready():
	if Inventory.local_turtle[NetworkManager.sessionID]["items"]["head"] != null:
		head_path = get_item_path("head", Inventory.local_turtle[NetworkManager.sessionID]["items"]["head"])
		head.setup(head_path)
		items.append("head")
		#head_image.mouse_entered.connect(_on_slot_hovered.bind(head_image))
		#head_image.mouse_exited.connect(_on_slot_unhovered.bind(head_image))
	
	if Inventory.local_turtle[NetworkManager.sessionID]["items"]["shell"] != null:
		shell_path = get_item_path("shell", Inventory.local_turtle[NetworkManager.sessionID]["items"]["shell"])
		shell.setup(shell_path)
		items.append("shell")
		
	if Inventory.local_turtle[NetworkManager.sessionID]["items"]["leftArm"] != null:
		leftArm_path = get_item_path("leftArm", Inventory.local_turtle[NetworkManager.sessionID]["items"]["leftArm"])
		leftArm.setup(leftArm_path)
		items.append("leftArm")
		
	if Inventory.local_turtle[NetworkManager.sessionID]["items"]["rightArm"] != null:
		rightArm_path = get_item_path("rightArm", Inventory.local_turtle[NetworkManager.sessionID]["items"]["rightArm"])
		rightArm.setup(rightArm_path)
		items.append("rightArm")
		
	if Inventory.local_turtle[NetworkManager.sessionID]["items"]["legs"] != null:
		legs_path = get_item_path("legs", Inventory.local_turtle[NetworkManager.sessionID]["items"]["legs"])
		legs.setup(legs_path)
		items.append("legs")
		
func get_item_path(body_part, item_name):
	if body_part == "leftArm" or body_part == "rightArm":
		body_part = "arm"
	var tres_instance = ItemPassivePool.call(body_part, item_name)
	return tres_instance

func tick(player):
	for appendage in items:
		match appendage:
			"head":
				if head.cooldown_remaining == 0:
					head.start_cooldown()
				head.tick(player.head_cooldown)
			
			"shell":
				if shell.cooldown_remaining == 0:
					shell.start_cooldown()
				shell.tick(player.shell_cooldown)
				
			"leftArm":
				if leftArm.cooldown_remaining == 0:
					leftArm.start_cooldown()
				leftArm.tick(player.left_arm_cooldown)

			"rightArm":
				if rightArm.cooldown_remaining == 0:
					rightArm.start_cooldown()
				rightArm.tick(player.right_arm_cooldown)
			
			"legs":
				if legs.cooldown_remaining == 0:
					legs.start_cooldown()
				legs.tick(player.legs_cooldown)
