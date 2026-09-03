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
var damage = 50

var sim_position
var sim_rotation

var initial_speed
var throw_angle_degrees
const gravit = 9.8
var start_tick 

var throw_direction

var z_axis = 0
var is_launch = false
var rotation_speed = PI * 3
@onready var sprite = $AnimatedSprite2D

func _ready():
	Inventory.projectiles.append(self)
	start_position = global_position
	sim_position = global_position
	sim_rotation = rotation
	distance = start_position.distance_to(final_position)
	start_tick = user.curr_tick
	
func _process(delta):
	position = position.lerp(sim_position, 0.25)
	if sim_position.distance_to(final_position) < 100:
		active = true

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
		launchProjectile(sim_position, final_position - start_position, distance, 60)
		
	if is_launch == true:
		z_axis = initial_speed * sin(deg_to_rad(throw_angle_degrees)) * (curr_tick - start_tick) - 0.5 * gravit * pow((curr_tick - start_tick), 2)
		
		if z_axis > 0:
			var x_axis = initial_speed * cos(deg_to_rad(throw_angle_degrees)) * (curr_tick - start_tick)
			sim_position = start_position + throw_direction * x_axis
			$AnimatedSprite2D.rotation += rotation_speed * (tick_rat / 2)
			$AnimatedSprite2D.position.y = -z_axis
		
		else:
			$AnimatedSprite2D.rotation = 0

	
func hit(body):
	if body == target:
		if active == true:
			if body.grounded == true and body.height == -50:
				if self in Inventory.projectiles:
					Inventory.projectiles.erase(self)
					$AnimatedSprite2D.play("snap")
					if body.invincible == false:
						#body.take_damage(damage)
						body.invin_frames(damage)
					await $AnimatedSprite2D.animation_finished
					#await get_tree().create_timer(1.0).timeout
					queue_free()
