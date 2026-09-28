extends Control

@onready var icon = $Icon
@onready var cooldown_overlay = $CooldownOverlay

var item
var cooldown := 0.0
var cooldown_remaining := 0.0

func _ready() -> void:
	cooldown_overlay.visible = false

func setup(new_item):
	item = new_item
	icon.texture = item.icon
	icon.size = Vector2(250, 250)
	icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	
	cooldown = item.cooldown
	cooldown_remaining = 0
	

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
