extends Area2D

@onready var sprite = $AnimatedSprite2D


@export var speed: float = 2400
@export var damage: float = 20.0

var target
var user
var start_position
var target_position
var direction
var return_tick = 0
var returning = false
var sim_position
var outbound_tick = 0
var outbound_control_point
var middle_point
var arc_height = 1000.0
var offset = Vector2(0, 200)

var curve_t = 0.0
var is_launch = false
var start_tick
var ground_trap = false
var return_position
var arm

func _ready():
	Inventory.projectiles.append(self)
	sim_position = global_position
	sprite.play("default")
	launch()
	if Inventory.server_turtles[user.id]["items"]["leftArm"] == "boomerang":
		arm = "leftArm"
	elif Inventory.server_turtles[user.id]["items"]["rightArm"] == "boomerang":
		arm = "rightArm"
	else:
		arm = null
	
func _process(delta):
	position = position.lerp(sim_position, 0.25)
	if transform.x.x < 0:
		sprite.flip_v = true
	else:
		sprite.flip_v = false

func launch():
	start_position = global_position
	target_position = target.global_position + offset
	direction = (target_position - start_position).normalized()
	middle_point = (start_position + target_position) / 2.0 + direction.rotated(PI / 2.0) * arc_height
	rotation = direction.angle()

func tick(curr_tick, tick_rat):
	if not returning:
		var step = speed * tick_rat
		curve_t += step / start_position.distance_to(target_position)
		curve_t = clampf(curve_t, 0.0, 1.0)
		var beginning_pull = pow(1.0 - curve_t, 2) * start_position
		var middle_control_point = 2.0 * (1.0 - curve_t) * curve_t * middle_point
		var end_pull = pow(curve_t, 2) * target_position
		sim_position = beginning_pull + middle_control_point + end_pull
		if curve_t >= 1.0:
			curve_t = 0
			return_position = user.global_position + offset
			arc_height *= -1
			middle_point = (return_position + target_position) / 2.0 + direction.rotated(PI / 2.0) * arc_height
			returning = true
	
	else:
		if curve_t >= 1.0:
			sim_position += direction * speed * tick_rat
			if abs(sim_position.distance_to(return_position)) > 10000:
				Inventory.projectiles.erase(self)
				queue_free()
		else:
			direction = (return_position - sim_position).normalized()
			var step = speed * tick_rat
			curve_t += step / target_position.distance_to(return_position)
			curve_t = clampf(curve_t, 0.0, 1.0)
			var beginning_pull = pow(1.0 - curve_t, 2) * target_position
			var middle_control_point = 2.0 * (1.0 - curve_t) * curve_t * middle_point
			var end_pull = pow(curve_t, 2) * return_position
			sim_position = beginning_pull + middle_control_point + end_pull

	
func hit(body):
	if body == target:
		if self in Inventory.projectiles:
			if body.invincible == false:
				body.invin_frames(damage)
	elif body != user:
		if self in Inventory.projectiles:
			if body.invincible == false:
				body.invin_frames(damage)

func _on_body_entered(body: Node2D) -> void:
	if body == user and returning == true:
		if self in Inventory.projectiles:
			Inventory.projectiles.erase(self)
			queue_free()
			if arm == "leftArm":
				user.left_arm_cooldown = 0
			elif arm == "rightArm":
				user.right_arm_cooldown = 0
				
