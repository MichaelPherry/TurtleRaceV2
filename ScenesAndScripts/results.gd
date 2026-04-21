extends CanvasLayer

func _ready():
	get_node("AnimationPlayer").play("TransIn")

func _on_button_button_down() -> void:
	get_node("AnimationPlayer").play("TransOut")
	await get_tree().create_timer(1.0).timeout
	get_tree().paused = false
	get_tree().change_scene_to_file("res://ScenesAndScripts/shop.tscn")
