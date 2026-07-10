extends Area2D

var target
var user
var final_position
var turn_speed = 200
var speed = 2500
var close_enough = 100
var ground_trap = true
var active = false

var sim_position
var sim_rotation

func _ready():
	Inventory.projectiles.append(self)
	sim_position = global_position
	sim_rotation = rotation
	#print("Tick: ", user.curr_tick)
	#print("Target Y: ", final_position.y)
	#print("RNG state before: ", user.rng.state)
	#print("RNG state after: ", user.rng.state)
	#print("")
	
func _process(delta):
	if sim_position.distance_to(final_position) < close_enough:
		speed = 0
		rotation = 0
		active = true
		return
		

	position = position.lerp(sim_position, 0.25)
	rotation = lerp_angle(rotation, sim_rotation, 0.25)

func tick():
	var to_target = (final_position - sim_position).normalized()
	var target_angle = to_target.angle()

	sim_rotation = target_angle
	var direction = Vector2.RIGHT.rotated(sim_rotation)
	sim_position += direction * speed * user.tick_rat * user.projectile


func _on_body_entered(body):
	return
	if body == target:
		if active == true:
			if body.grounded == true:
				queue_free()
				if body.invincible == false:
					#body.take_damage(damage)
					body.invin_frames()

func hit(body):
	if body == target:
		if active == true:
			if body.grounded == true:
				queue_free()
				Inventory.projectiles.erase(self)
				if body.invincible == false:
					#body.take_damage(damage)
					body.invin_frames()
