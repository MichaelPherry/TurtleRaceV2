extends Area2D

@export var speed: float = 1200
var target
var turn_speed = 200
var damage = 1
var user
var mult
@onready var sprite = $AnimatedSprite2D

# Called when the node enters the scene tree for the first time.
func _ready():
	sprite.play('Swim')
	pass
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	
	if transform.x.x < 0:
		sprite.flip_v = true
	else:
		sprite.flip_v = false
		
	var to_target = (target.global_position - global_position).normalized()
	var target_angle = to_target.angle()
	rotation = lerp_angle(rotation, target_angle, turn_speed * delta)
	position += transform.x * speed * delta *  user.projectile


func _on_body_entered(body):
	if body == target:
		queue_free()
		if body.invincible == false:
			pass
			#body.take_damage(damage)
			body.invin_frames()
