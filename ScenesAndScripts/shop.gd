extends Node2D

@onready var one = $One
@onready var two = $Two
@onready var three = $Three

func _ready():
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_button_button_down():
	NetworkManager.send_message()
	
	get_tree().change_scene_to_file("res://ScenesAndScripts/main.tscn")

func _on_fissile():
	Inventory.turtle_items[NetworkManager.sessionID]["leftArm"] = "fissile"

func _on_eel():
	Inventory.turtle_items[NetworkManager.sessionID]["leftArm"] = "eel_spit"

func _on_mystery(): 
	Inventory.turtle_items[NetworkManager.sessionID]["leftArm"] = "mystery_item"
