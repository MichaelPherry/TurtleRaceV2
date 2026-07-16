extends Node2D

@onready var background = $RaccoonBackground
var body_part = "leftArm"

func _ready():
	background.play("default")
	await get_tree().create_timer(1.0).timeout
	NetworkManager.send_message("enter_shop", "enter_shop")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_button_down():
	NetworkManager.send_message("submit_turtle", Inventory.local_turtle[NetworkManager.sessionID])
	
	
func _on_fissile():
	Inventory.local_turtle[NetworkManager.sessionID][body_part] = "fissile"

func _on_eel():
	Inventory.local_turtle[NetworkManager.sessionID][body_part] = "m1_helmet"

func _on_mystery(): 
	Inventory.local_turtle[NetworkManager.sessionID][body_part] = "bear_trap"

func _on_left_arm():
	body_part = "leftArm"
	
func _on_right_arm():
	body_part = "rightArm"

func _on_head():
	body_part = "head"

func _on_shell():
	body_part = "shell"

func _on_legs():
	body_part = "legs"
