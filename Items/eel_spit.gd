extends Area2D

var target
var user
var speed = 1600
var time = 1.0
var halfway
var dist
var current_dist
var arch
var coll_id
@onready var sprite = $AnimatedSprite2D

func _ready():
	sprite.play("EelSpit")
#	set_collision_mask_value(coll_id, true)
	launch_to()
	
func _physics_process(delta):
	if transform.x.x < 0:
		sprite.flip_v = true
	else:
		sprite.flip_v = false
	
	velocity.y += gravity * delta
	move_and_slide()

func get_predicted_position():
	dist = global_position.distance_to(target.global_position)
	var time = dist / speed
	return target.global_position + target.velocity * time
	

func launch_to():
	var predicted_pos = get_predicted_position()
	var dir = (predicted_pos - global_position).normalized()
	velocity.x = dir.x * speed
	velocity.y = -800

	
func _on_body_entered(body):
	if body == target:
		queue_free()
		if body.invincible == false:
			pass
			#body.take_damage(damage)
			body.invin_frames()
