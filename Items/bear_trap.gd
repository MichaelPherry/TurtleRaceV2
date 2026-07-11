extends Area2D

var target
var user
var start_position
var final_position
var turn_speed = 200
var speed = 2500
var close_enough = 100
var ground_trap = true
var active = false
var arc_height = 100
var distance
var progress = 0

var sim_position
var sim_rotation

func _ready():
	Inventory.projectiles.append(self)
	start_position = global_position
	sim_position = global_position
	sim_rotation = rotation
	distance = start_position.distance_to(final_position)
	#print("Tick: ", user.curr_tick)
	#print("Target Y: ", final_position.y)
	#print("RNG state before: ", user.rng.state)
	#print("RNG state after: ", user.rng.state)
	#print("")
	
func _process(delta):
	if sim_position.distance_to(final_position) < close_enough or progress >= 1:
		speed = 0
		rotation = 0
		active = true
		return
		

	position = position.lerp(sim_position, 0.25)
	#rotation = lerp_angle(rotation, sim_rotation, 0.25)

func tick():
	var to_target = (final_position - sim_position).normalized()
	var target_angle = to_target.angle()

	progress += (speed * user.tick_rat) / distance
	
	sim_rotation = target_angle
	var direction = Vector2.RIGHT.rotated(sim_rotation)
	sim_position.y += sin(progress * PI) * arc_height
	sim_position += direction * speed * user.tick_rat * user.projectile
	
func hit(body):
	if body == target:
		if active == true:
			if body.grounded == true:
				if self in Inventory.projectiles:
					Inventory.projectiles.erase(self)
					$AnimatedSprite2D.play("snap")
					if body.invincible == false:
						#body.take_damage(damage)
						body.invin_frames()
					await $AnimatedSprite2D.animation_finished
					#await get_tree().create_timer(1.0).timeout
					queue_free()
