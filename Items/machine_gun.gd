extends Node2D

@export var speed: float = 3000
var bullet = preload("res://Items/projectiles/bullet.tscn")
var target
var user
var bullet_amount = 8
var cone_angle = 50
var ground_trap = false

func use_item(user_target):
	target = user_target
	var target_direction = (target.sim_position - global_position).normalized()
	var base_angle = target_direction.angle()
	
	for i in (bullet_amount * user.projectile_amt):
		var gun_projectile = bullet.instantiate()
		var spread = deg_to_rad(user.rng.randf_range(-cone_angle / 2, cone_angle / 2)) 
		var direction = Vector2.RIGHT.rotated(base_angle + spread)
		gun_projectile.user = user
		gun_projectile.target = target
		gun_projectile.global_position = user.global_position
		gun_projectile.direction = direction
		get_tree().current_scene.add_child(gun_projectile)
		await Inventory.wait_ticks(user, 0.1)
