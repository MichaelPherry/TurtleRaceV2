extends Node2D
var target
var user
var fissile = preload("res://Items/projectiles/fissile.tscn") 
var flip = false
var bullet_amount = 1

@onready var firepoint = $AnimatedSprite2D/Firepoint
@onready var sprite = $AnimatedSprite2D

	
#func fire(target):
	#fissile = fissile_scene.instantiate()
	#fissile.user = user
	#fissile.target = target
	#fissile.global_position = user.global_position
	#add_child(fissile)
	
func use_item(user_target):
	target = user_target
	var target_direction = (target.sim_position - global_position).normalized()
	var base_angle = target_direction.angle()
	
	for i in (bullet_amount * user.projectile_amt):
		var gun_projectile = fissile.instantiate()
		#var spread = deg_to_rad(user.rng.randf_range(-cone_angle / 2, cone_angle / 2)) 
		var direction = Vector2.RIGHT.rotated(base_angle)
		gun_projectile.user = user
		gun_projectile.target = target
		gun_projectile.global_position = user.global_position
		gun_projectile.direction = direction
		get_tree().current_scene.add_child(gun_projectile)
		await Inventory.wait_ticks(user, 0.1)
