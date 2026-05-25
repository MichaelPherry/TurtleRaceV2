extends Area2D

var target
var user
var final_position
var min = 1000
var max
var turn_speed = 200
var speed = 2500
var close_enough = 100

func _ready():
	max = 7500
	if (target.global_position.y + min) > max:
		final_position = Vector2(target.global_position.x, max)
	else:
		final_position = Vector2(target.global_position.x, randi_range(target.global_position.y + min, max))

func _process(delta):
	if self.position.distance_to(final_position) < close_enough:
		speed = 0
		rotation = 0
		return
		

	var to_target = (final_position - global_position).normalized()
	var target_angle = to_target.angle()
	rotation = lerp_angle(rotation, target_angle, turn_speed * delta)
	self.position += transform.x * speed * delta


func _on_body_entered(body: Node2D) -> void:
	if body == target:
		queue_free()
		if body.invincible == false:
			pass
			#body.take_damage(damage)
			body.invin_frames()
