extends Area2D

@export var speed := 500
@export var gravit := 800
@export var homing_speed := 100

var distance
var target
var user
var velocity := Vector2.ZERO
var homing
var height := 0
var vertical_velocity
var init_pos
var turn_speed = 50
@onready var sprite = $AnimatedSprite2D

func _ready():
	#print("Target", target.id, " User ", user.id)
	init_pos = global_position.x
	distance = target.global_position.x - init_pos
	vertical_velocity = - global_position.y + target.global_position.y
	if vertical_velocity > -800:
		vertical_velocity = -800
	sprite.play("EelSpit")
	velocity = Vector2(distance / 2, vertical_velocity )
#	set_collision_mask_value(coll_id, true)

func _physics_process(delta):
	if transform.x.x < 0:
		sprite.flip_v = true
	else:
		sprite.flip_v = false
	
	if not homing:
		initial_arch(delta)
		if abs(init_pos - global_position.x) > (abs(distance) / 2):
			homing = true
	else:
		#homing_arch(delta)
		initial_arch(user.tick_rat)
	#vertical_velocity += gravit * delta
	#height -= vertical_velocity * delta
	#homing_arch(delta)

func initial_arch(delta):
	velocity.y += gravit * user.tick_rat
	position += velocity * user.tick_rat
	
func homing_arch(delta):
	var direction = (target.global_position - global_position).normalized()
	velocity = velocity.lerp(direction * homing_speed, 500 * user.tick_rat)
	var to_target = (target.global_position - global_position).normalized()
	var target_angle = to_target.angle()
	rotation = lerp_angle(rotation, target_angle, turn_speed * user.tick_rat)
	position += transform.x * speed * user.tick_rat *  user.projectile
	
func _on_body_entered(body):
	if body == target:
		queue_free()
		if body.invincible == false:
			pass
			#body.take_damage(damage)
			body.invin_frames()
