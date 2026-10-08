extends Control

@onready var icon = $Icon
@onready var cooldown_overlay = $CooldownOverlay
@onready var tooltip = $Tooltop
@onready var sell = $Sell

var item
var appendage
var cooldown := 0.0
var cooldown_remaining := 0.0
var half_price
signal item_sold()

func _ready() -> void:
	item = null
	cooldown_overlay.visible = false
	mouse_entered.connect(_on_mouse_entered)
	mouse_exited.connect(_on_mouse_exited)
	sell.mouse_entered.connect(_on_mouse_entered)
	sell.mouse_exited.connect(_on_mouse_exited)
	sell.hide()

func setup(body_part, new_item):
	appendage = body_part
	item = new_item
	half_price = item.price / 2
	icon.texture = item.icon
	icon.size = Vector2(250, 250)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	cooldown = item.cooldown
	cooldown_remaining = 0

func delete_self():
	appendage = null
	item = null
	half_price = null
	icon.texture = null
	cooldown = 0.0
	

func start_cooldown():
	cooldown_remaining = cooldown
	cooldown_overlay.visible = true
	cooldown_overlay.size.y = 0
	cooldown_overlay.position.y = size.y


func tick(item_cooldown):
	if cooldown_remaining <= 0:
		return

	cooldown_remaining = item_cooldown

	var percent = 1.0 - (cooldown_remaining / cooldown)

	cooldown_overlay.size.y = size.y * percent
	cooldown_overlay.position.y = size.y - cooldown_overlay.size.y

	if cooldown_remaining <= 0:
		cooldown_remaining = 0
		cooldown_overlay.visible = false

func _on_mouse_entered():
	if item == null:
		return
	
	if get_tree().current_scene.scene_file_path != "res://ScenesAndScripts/main.tscn":
		sell.text = "SELL $" + str(half_price)
		sell.visible = true
	create_tween().tween_property(self, "scale", Vector2(1.1, 1.1), 0.1)
	self.modulate = Color(1.3, 1.3, 1.3)
	tooltip.show_item(item)

func _on_mouse_exited():
	if item == null:
		return
	var timer = get_tree().create_timer(0.2)
	sell.visible = false
	create_tween().tween_property(self, "scale", Vector2.ONE, 0.1)
	self.modulate = Color.WHITE
	tooltip.hide_tooltip()

func _on_sell_pressed() -> void:
	Inventory.local_turtle[NetworkManager.sessionID]["econ"]["gold"] += half_price
	var item_name = Inventory.local_turtle[NetworkManager.sessionID]["items"][appendage]
	Inventory.local_turtle[NetworkManager.sessionID]["items"][appendage] = null
	if appendage == "leftArm" or appendage == "rightArm":
		appendage = "arm"
	ItemPassivePool.total_pool[appendage].append(item_name)
	_on_mouse_exited()
	delete_self()
	item_sold.emit()
