extends Area2D

var target
var user
var final_position
var min = 1000
var max
var turn_speed = 200
var speed = 2500
var close_enough = 100
var ground_trap = true
var active = false
var rng

func _ready():
	rng = RandomNumberGenerator.new()
	rng.seed = Inventory.seed
	max = 7500
	if (target.global_position.y + min) > max:
		final_position = Vector2(target.global_position.x, max)
	else:
		final_position = Vector2(target.global_position.x, rng.randi_range(target.global_position.y + min, max))

func _process(delta):
	if self.position.distance_to(final_position) < close_enough:
		speed = 0
		rotation = 0
		active = true
		return
		

	var to_target = (final_position - global_position).normalized()
	var target_angle = to_target.angle()
	rotation = lerp_angle(rotation, target_angle, turn_speed * delta)
	self.position += transform.x * speed * delta


func _on_body_entered(body):
	if body == target:
		if active == true:
			if body.grounded == true:
				queue_free()
				if body.invincible == false:
					pass
					#body.take_damage(damage)
					body.invin_frames()
