extends Node2D

@export var speed: float = 3000
var eel = preload("res://Items/projectiles/eel.tscn") 
var target
var user
var bullet_amount = 1
var ground_trap = false
var user_keywords
	
func use_item(user_target):
	target = user_target
	var target_direction = (target.sim_position - global_position).normalized()
	var base_angle = target_direction.angle()
	user_keywords = user.item_types["Gun"]
	user_keywords.append("Stun")

	for i in (bullet_amount * user.projectile_amt):
		var gun_projectile = eel.instantiate()
		var direction = base_angle
		gun_projectile.user = user
		gun_projectile.target = target
		gun_projectile.global_position = user.global_position
		gun_projectile.direction = direction
		gun_projectile.keyword_attributes = user_keywords
		get_tree().current_scene.add_child(gun_projectile)
		await Inventory.wait_ticks(user, 0.2)
