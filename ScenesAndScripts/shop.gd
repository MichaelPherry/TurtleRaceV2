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
	await get_tree().create_timer(0.3).timeout
	get_tree().change_scene_to_file("res://ScenesAndScripts/main.tscn")
