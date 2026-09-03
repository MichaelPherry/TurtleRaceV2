extends Node

var user
var target
var effect = true
var laser_amount = 1
var laser = preload("res://Items/projectiles/laser_sweep.tscn") 
var user_keywords = []

func activate_effect():
	var players = get_tree().get_nodes_in_group("racing")
	players.sort_custom(func(a,b):
		return a.id < b.id
	)
	rand_shuffle(user, players)
	if target == null:
		return
	for i in (laser_amount * user.projectile_amt):
		var gun_projectile = laser.instantiate()
		gun_projectile.user = user
		gun_projectile.target = target
		gun_projectile.global_position = user.global_position
		gun_projectile.keyword_attributes = user_keywords
		get_tree().current_scene.add_child(gun_projectile)
		await Inventory.wait_ticks(user, 0.2)
	
func rand_shuffle(player, normal_array):
	for i in range(normal_array.size() - 1, 0, -1):
		Inventory.rng_calls += 1

		var rand_number = player.rng.randi_range(0, i)
		var temp = normal_array[i]
		normal_array[i] = normal_array[rand_number]
		normal_array[rand_number] = temp
	if normal_array.size() <= 1:
		return []
	if normal_array[0] == player:
		normal_array.pop_front()
	
	target = null
	for i in normal_array:
		if i != player:
			target = i
			break
