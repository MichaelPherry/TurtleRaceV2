extends Node2D
var target
var turn_speed = 200
var user
var mult
var ground_trap = false

var start_angle
var end_angle
var start_tick
var sweep_ticks = 30

var sim_position: Vector2
var sim_rotation: float

func _ready():
	Inventory.projectiles.append(self)
	get_laser_direction()
	rotation = start_angle
	start_tick = user.curr_tick

func get_laser_direction():
	if target.position.x > user.position.x:
		start_angle = deg_to_rad(65)
		end_angle = deg_to_rad(-65)
	else:
		start_angle = deg_to_rad(135)
		end_angle = deg_to_rad(225)
	
func tick(curr_tick, tick_rat):
	var elapsed_ticks = curr_tick - start_tick
	var progress = float(elapsed_ticks) / float(sweep_ticks)
	progress = clamp(progress, 0.0, 1.0)
	rotation = lerp(start_angle, end_angle, progress)
	position = user.global_position
	if progress >= 1:
		queue_free()
		Inventory.projectiles.erase(self)

func hit():
	pass

func _on_area_2d_body_entered(body: Node2D) -> void:
	if body != user:
		if body.invincible == false:
			body.invin_frames()
