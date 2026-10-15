extends CanvasLayer

var parent_scene
func _ready():
	get_node("AnimationPlayer").play("TransIn")
	parent_scene = get_parent().name
	
func _on_button_button_down() -> void:
	if parent_scene == "Boss":
		NetworkManager.send_message("start_race_after_boss", "start_race_after_boss")
		
	elif parent_scene == "Main":
		Inventory.race_started = false
		get_node("AnimationPlayer").play("TransOut")
		await get_tree().create_timer(1.0).timeout
		get_tree().change_scene_to_file("res://ScenesAndScripts/shop.tscn")
