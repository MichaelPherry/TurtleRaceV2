extends Area2D

var target
var user
var sim_position
var sim_rotation
var distance
var throw_direction
var throw_angle_degrees
var initial_speed
var arc_height = 100
var speed = 1200
var start_position

var progress = 0
var gravit = 9.8
var z_axis = 0
var is_launch = false
var start_tick
var ground_trap = false

func _ready():
	Inventory.projectiles.append(self)
	start_position = global_position
	sim_position = global_position
	sim_rotation = rotation
	distance = sim_position.distance_to(target.sim_position)
	start_tick = user.curr_tick
	$AnimatedSprite2D.play("default")

func _process(delta):
	position = position.lerp(sim_position, 0.25)
	if sim_position.distance_to(target.sim_position) < 100:
		pass
		
func launchProjectile(initial_pos, direction, desired_distance, desired_angle_deg):
	start_position = initial_pos
	throw_direction = direction.normalized()
	throw_angle_degrees = desired_angle_deg
	
	initial_speed = pow(desired_distance * gravit / sin(2 * deg_to_rad(desired_angle_deg)), 0.5)
	
	sim_position = start_position
	z_axis =  0
	is_launch = true

func tick(curr_tick, tick_rat):
	if is_launch == false:
		launchProjectile(sim_position, target.sim_position - start_position, distance, 60)
		
	if is_launch == true:
		z_axis = initial_speed * sin(deg_to_rad(throw_angle_degrees)) * (user.curr_tick - start_tick) - 0.5 * gravit * pow((user.curr_tick - start_tick), 2)
		
		if z_axis > 0:
			var x_axis = initial_speed * cos(deg_to_rad(throw_angle_degrees)) * (user.curr_tick - start_tick)
			sim_position = throw_direction * x_axis
	
func hit(body):
	if body == target:
		if body.grounded == true:
			if self in Inventory.projectiles:
				Inventory.projectiles.erase(self)
				if body.invincible == false:
					body.invin_frames()
				queue_free()
