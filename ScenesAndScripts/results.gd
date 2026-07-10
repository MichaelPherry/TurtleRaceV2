extends CanvasLayer

func _ready():
	get_node("AnimationPlayer").play("TransIn")

func _on_button_button_down() -> void:
	Inventory.race_started = false
	get_node("AnimationPlayer").play("TransOut")
	await get_tree().create_timer(1.0).timeout
	#for projectile in Inventory.projectiles:
		#projectile.queue_free()
		#Inventory.projectiles.erase(projectile)
	get_tree().change_scene_to_file("res://ScenesAndScripts/shop.tscn")
